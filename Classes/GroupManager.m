//
//  UnreadMessageObserver.m
//  groups
//
//  Created by Cragin Godley on 12/7/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "App.h"
#import "Api.h"
#import "GroupManager.h"
#import "Group.h"
#import "AppViewController.h"
#import "ExtensionConduit.h"
#import "PNBackgroundTaskElf.h"
#import "PNVideoResampler.h"

@interface GroupManager () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation GroupManager

+(GroupManager*)manager {

    static GroupManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GroupManager alloc] init];
    });

    return manager;
}

-(id)init {
    self = [super init];
    if(self) {
        [self initializeFetchController];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(initializeFetchController)
                                                     name:kLoginStateNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fillExtensionConduit)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

        self.unreadGroups = [NSMutableArray arrayWithCapacity:8];
    }
    return self;
}

-(void)initializeFetchController {
    if ([App userId]) {
        NSError *error;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Group"];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY members.id == %@", [App userId]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"last_message_at" ascending:NO]];
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                   managedObjectContext:[App moc]
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
        self.fetchController.delegate = self;
        if(![self.fetchController performFetch:&error])
            NSLog(@"%@",error);
        [self updateUnreadCount];
    }
    else {
        self.fetchController = nil;
        self.unreadCount = 0;
        self.totalCount = 0;
    }
}

- (NSArray*)groups {
    return self.fetchController.fetchedObjects;
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    if([App isLoggedIn]) {
        Group *group = anObject;
        if(group.isGroupValue) {
            if(NSFetchedResultsChangeDelete == type)
                [[Api sharedApi].fayeClient unsubscribeFromChannel:group.channel];

            else if (NSFetchedResultsChangeInsert == type) {
                [[Api sharedApi].fayeClient subscribeToChannel:group.channel];
            }
        }
    }
}

-(void)updateUnreadCount {
    if (!self.fetchController.fetchedObjects) return;

    [self.fetchController.managedObjectContext performBlock:^{
        NSSet *groups = [NSSet setWithArray:self.fetchController.fetchedObjects];
        int count = 0;
        [self.unreadGroups removeAllObjects];
        for (Group *group in groups) {
            if (group.hasUnreadMessages && !group.isHiddenValue && !group.isDeleted) {
                count++;
                [self.unreadGroups addObject:group];
            }
        }
        self.unreadCount = count;
        self.totalCount = self.fetchController.fetchedObjects.count;
    }];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateUnreadCount];
    if (UIApplicationStateActive != [UIApplication sharedApplication].applicationState) {
        [self fillExtensionConduit];
    }
}

- (void)refreshGroupsWithCompletion:(void (^)(NSSet* groups))completion {

    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:1];

    NSArray* groups = self.fetchController.fetchedObjects;
    NSMutableDictionary* ranks = [NSMutableDictionary dictionaryWithCapacity:groups.count];

    NSArray* emptyGroups = [groups filteredArrayUsingBlock:^BOOL(Group* group, NSDictionary *bindings) {
        return group.last_message == nil;
    }];

    int messagesPerEmptyThread = emptyGroups.count > 30 ? 2 : 3;

    for (Group* g in groups) {
        if (g.last_message) {
            ranks[g.id] = g.last_message.rank;
        }
        else {
            int last_seen = g.last_seen_rankValue;
            int rank = MAX(-1, last_seen-messagesPerEmptyThread);
            ranks[g.id] = @(rank);
        }
    }

    params[@"last_seen_ranks"] = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:ranks options:0 error:nil] encoding:NSUTF8StringEncoding];

    self.isLoading = YES;
    [[Api sharedApi] postPath:@"/conversations"
                   parameters:params
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         self.isLoading = NO;
                         NSSet* groups = [entities setOfClass:[Group class]];

                         if (completion) completion(groups);
                     }];
}

// Save 3 most recent snaps (not sent by user) to conduit.
// The most recent is added *last*
- (void)fillExtensionConduit {

    static BOOL isFilling;
    if (isFilling) return;
    isFilling = YES;

    __block NSArray* objs = self.fetchController.fetchedObjects;
    if (objs.count == 0) return;

    [PNBackgroundTaskElf doIt:^(PNBackgroundTaskElf *elf) {
        __block ExtensionConduit* dooit = [ExtensionConduit shared];
        [dooit reloadCacheInfo];

        __block int count = 0;
        int x = 0;
        SkyMessage* msg;
        NSMutableArray* fetchMe = [NSMutableArray new];
        do {
            Group* g = [objs objectAtIndex:x];
            msg = g.lastOtherUserMessage;
            if (!msg.user.isMe && (msg.hasVideo || msg.hasImage)) {
                [fetchMe addObject:msg];
                count++;
            }
            x++;
        } while (count < 3 && x < objs.count);

        // usernames already in conduit:
        NSMutableArray* existingSnapIds = [[[dooit allSnaps] mapUsingBlock:^id(ExtensionConduitItem* item) {
            return item.properties[@"snap_id"];
        }] mutableCopy];

        dispatch_group_t fetchGroup = dispatch_group_create();

        // reverse order so that newest has the largest timestamp in the conduit.
        for (SkyMessage* m in fetchMe.reverseObjectEnumerator) {

            // don't add if already there
            if ([existingSnapIds containsObject:m.id]) {
                NSLog(@"snap %@ (%@) already in conduit", m.id, m.user.username);
                continue;
            }

            dispatch_group_enter(fetchGroup);

            __weak SkyMessage* weakMsg = m;
            [m fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *videoOverlay) {
                if (!weakMsg) {
                    dispatch_group_leave(fetchGroup);
                    return;
                }

                NSString* username = weakMsg.user.username ?: weakMsg.group.other_user.username ?: @"";
                NSDictionary* props = @{@"created_at":weakMsg.created_at,
                                        @"username":username,
                                        @"snap_id":weakMsg.id};
                if (photo) {
                    UIImage* smallPhoto = [photo imageByScalingProportionallyToFit:CGSizeMake(240,400)];
                    NSLog(@"adding snap photo %@", weakMsg.id);
                    [existingSnapIds addObject:weakMsg.id];
                    [dooit addSnapWithImage:smallPhoto properties:props];
                    dispatch_group_leave(fetchGroup);
                }
                else if (videoUrl) {
                    [weakMsg fetchVideoPreviewWithCompletion:^(NSURL *previewUrl) {
                        NSLog(@"adding snap video %@", weakMsg.id);
                        [existingSnapIds addObject:weakMsg.id];
                        [dooit addSnapWithVideoUrl:previewUrl properties:props];
                        dispatch_group_leave(fetchGroup);
                    }];
                }
                else {
                    dispatch_group_leave(fetchGroup);
                }
            }]; // fetch
        } // for

        dispatch_group_notify(fetchGroup, dispatch_get_main_queue(), ^{
            [dooit pruneSnapsToCount:3];
            isFilling = NO;
            [elf doneIt];
        });
    }];
}

-(void)dealloc {
    self.fetchController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
