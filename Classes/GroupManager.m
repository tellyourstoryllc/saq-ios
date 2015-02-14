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

-(void)dealloc {
    self.fetchController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
