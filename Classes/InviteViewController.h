//
//  DirectoryViewController.h
//  groups
//
//  Created by Jim Young on 2/4/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNSimpleTableViewController.h"
#import "Directory.h"

@class InviteViewController;

@protocol InviteViewDelegate <NSObject>

-(void)inviteController:(InviteViewController*)controller finishedSelectingWithPeople:(NSArray*)people;

@optional

-(void)inviteController:(InviteViewController*)controller didSelectPerson:(DirectoryItem*)person;
-(void)inviteController:(InviteViewController*)controller didDeselectPerson:(DirectoryItem*)person;

-(void)inviteController:(InviteViewController*)controller didAddEmailPerson:(DirectoryItem*)person;
-(void)inviteController:(InviteViewController*)controller didAddPhoneNumberPerson:(DirectoryItem*)person;

@end

@interface InviteViewController : PNSimpleTableViewController

@property (nonatomic, assign) id<InviteViewDelegate> delegate;

@property (nonatomic, strong) PNButton* doneButton;
@property (nonatomic, strong) PNLabel* titleLabel;
@property (nonatomic, strong) PNTextField* textField;
@property (nonatomic, strong) PNButton* addNewUserButton;

// An array of DirectoryItem
@property (nonatomic, strong) NSMutableArray* selectedPeopleArray;
@property (nonatomic, strong) NSMutableArray* excludedPeopleArray;

@end
