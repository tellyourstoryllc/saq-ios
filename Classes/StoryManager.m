//
//  StoryManager.m
//  SnapCracklePop
//
//  Created by Jim Young on 6/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "StoryManager.h"
#import "App.h"
#import "Api.h"
#import "Story.h"
#import "AppViewController.h"
#import "PNUserPreferences.h"
#import "PNBackgroundTaskElf.h"
#import "ExtensionConduit.h"
#import "PNVideoResampler.h"

@interface StoryManager () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray* unreadUsers;
@property (nonatomic) NSFetchedResultsController *fetchController;

@end

@implementation StoryManager

+(StoryManager*)manager {

    static StoryManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[StoryManager alloc] init];
    });

    return manager;
}

-(id)init {
    self = [super init];
    if(self) {
        self.unreadStories = [NSMutableArray arrayWithCapacity:8];
        self.unreadUsers = [NSMutableArray arrayWithCapacity:8];
        [self updateUnreadCount];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeFetchController) name:kLoginStateNotification object:nil];
    }
    return self;
}

-(void)initializeFetchController {
    self.fetchController.delegate = nil;
    
    if ([App userId]) {
        NSError *error;

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"User"];

        request.predicate = [NSPredicate predicateWithFormat:@"id != NULL AND id != %@ AND last_story != NULL AND last_story_at != NULL AND (last_seen_story_at = NULL OR last_seen_story_at < last_story_at)", [App userId]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"last_story_at" ascending:NO]];
        self.fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                   managedObjectContext:[App managedObjectContext]
                                                                     sectionNameKeyPath:nil
                                                                              cacheName:nil];
        self.fetchController.delegate = self;
        if(![self.fetchController performFetch:&error])
            NSLog(@"%@",error);
    }
    else {
        self.fetchController = nil;
        self.unreadCount = 0;
        self.totalCount = 0;
    }
}

-(void)updateUnreadCount {
    [self initializeFetchController];
    [self.fetchController.managedObjectContext performBlock:^{
        NSSet *users = [NSSet setWithArray:self.fetchController.fetchedObjects];
        int count = 0;
        [self.unreadStories removeAllObjects];
        [self.unreadUsers removeAllObjects];
        for (User *user in users) {
            if (user.username) {
                if (![self.unreadUsers containsObject:user.username]) {
                    count++;
                    [self.unreadUsers addObject:user.username];
                }
                [self.unreadStories addObject:user.last_story];
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

- (void)loadPublicFeedWithParams:(NSDictionary*)params
             andCompletion:(void (^)(NSSet* stories))completion {

    void (^updateBlock)(NSSet*) = ^(NSSet* stories) {
        for (Story* story in stories) {
            story.in_feedValue = YES;
        }
        [[stories anyObject] save];
    };

    [self loadFeedFromPath:@"/public_feed" withParams:params andCompletion:^(NSSet *stories) {
        updateBlock(stories);
        if (completion)
            completion(stories);
    }];
}

- (void)loadFeedFromPath:(NSString*)path
              withParams:(NSDictionary*)params
           andCompletion:(void (^)(NSSet* stories))completion {

    NSMutableDictionary* mutableParams = params ? [params mutableCopy] : [NSMutableDictionary dictionaryWithCapacity:2];
    mutableParams[@"limit"] = mutableParams[@"limit"] ?: @(50);
    mutableParams[@"offset"] = mutableParams[@"offset"] ?: @(0);

    self.isLoading = YES;

    [[Api sharedApi] postPath:path
                   parameters:mutableParams
                     callback:^(NSSet *entities, id responseObject, NSError *error) {

                         NSLog(@"feedme: %@ %@", path, responseObject);

                         NSSet* allUsers = [NSSet setWithArray:[[[entities setOfClass:[Story class]] allObjects] valueForKey:@"user_id"]];

                         NSSet* storySet = [entities setOfClass:[Story class]];
                         NSArray* storiesMissingUsers = [[storySet allObjects] filteredArrayUsingBlock:^BOOL(Story* story, NSDictionary *bindings) {
                             return story.user_id && !story.user;
                         }];

                         NSArray* missingUserIds = [storiesMissingUsers valueForKey:@"user_id"];
                         // Dedupe
                         missingUserIds = [[NSSet setWithArray:missingUserIds] allObjects];

                         // Load users unknown to client from API.
                         if (missingUserIds.count) {
                             NSArray* storyIds = [[storySet valueForKey:@"objectID"] allObjects];

                             [[Api sharedApi] postPath:@"/users"
                                            parameters:@{@"ids":[missingUserIds componentsJoinedByString:@","]}
                                              callback:^(NSSet *entities, id responseObject, NSError *error) {

                                                  NSManagedObjectContext* context = [App privateManagedObjectContext];
                                                  NSArray* users = [User findByIds:allUsers.allObjects inContext:context];
                                                  for (User* user in users) {
                                                      [user killDoppelganger]; // <-- just in case!
                                                      [user associateWithStories];
                                                      [user updateLastStory];
                                                  }
                                                  [context save:nil];

                                                  NSArray* stories = [storyIds mapUsingBlock:^id(id obj) {
                                                      return [context objectWithID:obj];
                                                  }];

                                                  self.isLoading = NO;
                                                  if (completion) {
                                                      NSSet* storySet = [NSSet setWithArray:stories];
                                                      completion(storySet);
                                                  }
                                              }];
                         }
                         else {
                             self.isLoading = NO;
                             if (completion)
                                 completion(storySet);
                         }
                     }
     ];
}

-(void)dealloc {
    self.fetchController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
