//
//  PeopleSearchController.m
//  NoMe
//
//  Created by Jim Young on 1/10/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "PeopleViewSearchController.h"
#import "Api.h"
#import "App.h"
#import "Story.h"
#import "SkyTag.h"

@interface PeopleViewSearchController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) NSTimer* searchTimer;
@property (nonatomic, strong) NSMutableArray* savedSearchTerms;
@end

@implementation PeopleViewSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    [self updatePeopleResultsController];
    [self updateStoryResultsController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchBar = [UISearchBar new];
    self.searchBar.placeholder = @"username, friend id, or #tag";
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate = self;

    [self.view addSubview:self.searchBar];

    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector(onSearchTimer) userInfo:nil repeats:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.searchBar.frame = self.view.bounds;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing)
        [self.searchBar becomeFirstResponder];
    else
        [self.searchBar resignFirstResponder];
}

- (NSArray*)searchTerms
{
    NSArray* ary = [self.searchBar.text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",# "]];
    // filter out empty strings.
    return [[ary filteredArrayUsingBlock:^BOOL(NSString* string, NSDictionary *bindings) {
        return string.length > 0;
    }] mapUsingBlock:^id(NSString* string) {
        return string.lowercaseString;
    }];
}

- (void)updatePeopleResultsController
{
    NSManagedObjectContext* context = [App managedObjectContext];

    NSFetchRequest *userRequest = self.peopleResults.fetchRequest ?: [[NSFetchRequest alloc] initWithEntityName:@"User"];
    userRequest.sortDescriptors = @[
                                    [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]
                                    ];
    userRequest.fetchLimit = 50;

    if ([[self searchTerms] count])
        userRequest.predicate = [NSPredicate predicateWithFormat:@"friend_code IN %@ OR username IN %@", [self searchTerms], [self searchTerms]];
    else
        userRequest.predicate = [NSPredicate predicateWithFormat:@"id = 'NOSUCHID'"];

    if (!self.peopleResults)
        self.peopleResults = [[NSFetchedResultsController alloc] initWithFetchRequest:userRequest
                                                                 managedObjectContext:context
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
    
    [self.peopleResults performFetch:nil];
}

- (void)updateStoryResultsController
{
    NSManagedObjectContext* context = [App managedObjectContext];

    NSFetchRequest *storyRequest = self.storyResults.fetchRequest ?: [[NSFetchRequest alloc] initWithEntityName:@"Story"];
    storyRequest.fetchLimit = 50;
    storyRequest.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:NO]
                                     ];

    if ([[self searchTerms] count])
        storyRequest.predicate = [NSPredicate predicateWithFormat:@"ANY tags.id like %@", [[self searchTerms] lastObject]];
    else
        storyRequest.predicate = [NSPredicate predicateWithFormat:@"id = 'NOSUCHID'"];

    if (!self.storyResults)
        self.storyResults = [[NSFetchedResultsController alloc] initWithFetchRequest:storyRequest
                                                                managedObjectContext:context
                                                                  sectionNameKeyPath:nil
                                                                           cacheName:nil];


    [self.storyResults performFetch:nil];
}

#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {

    static NSArray* lastSearchTerms;
    NSArray *searchTerms = [self searchTerms];

    if (![searchTerms isEqualToArray:lastSearchTerms]) {
        [self updatePeopleResultsController];
        [self updateStoryResultsController];
        [self.collection reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)]];
    }

    lastSearchTerms = searchTerms;
}


- (void)fetchStoriesTagged:(NSString*)tag {
    NSString* path = [NSString stringWithFormat:@"/stories/tags/%@", tag];

    [[Api sharedApi] postPath:path
                   parameters:@{@"limit":@(100)}
                     callback:^(NSSet *entities, id responseObject, NSError *error) {
                         NSSet* stories = [entities setOfClass:[Story class]];
                         if (stories.count) {
                             NSManagedObjectContext* context = [stories.anyObject managedObjectContext];
                             SkyTag* tagObj = [SkyTag findOrCreateById:tag inContext:context];
                             [tagObj.storiesSet addObjectsFromArray:stories.allObjects];
                             [context saveToRootWithCompletion:nil];
                         }
                     }];
}

- (void)onSearchTimer
{
    if (!_savedSearchTerms)
        _savedSearchTerms = [NSMutableArray new];

    NSArray *searchTerms = [self searchTerms];

    NSString* term = [searchTerms lastObject];
    if (term.length >= 4 && ![_savedSearchTerms containsObject:term]) {
        [_savedSearchTerms addObject:term];
        [self fetchStoriesTagged:term];
    }
}

@end
