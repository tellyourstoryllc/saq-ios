//
//  ContactsViewController.h
//  groups
//
//  Created by Jim Young on 1/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNSimpleTableViewController.h"
#import "RHAddressBook.h"
#import "RHPerson.h"

@protocol ContactsViewDelegate <NSObject>

-(void)finishedSelectingWithPeople:(NSArray*)people;

@optional
-(void)selectPerson:(RHPerson*)person;
-(void)deselectPerson:(RHPerson*)person;

@end

@interface ContactsViewController : PNSimpleTableViewController

@property (nonatomic, assign) id<ContactsViewDelegate> delegate;

@end
