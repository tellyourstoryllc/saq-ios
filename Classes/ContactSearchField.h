//
//  ContactSearchField.h
//  FFM
//
//  Created by Jim Young on 4/19/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//
#import "PNTextField.h"
#import "Directory.h"

@class ContactSearchField;

@protocol ContactSearchFieldDelegate <NSObject>
@optional
- (void)contactSearch:(ContactSearchField*)searchField didSelect:(DirectoryItem*)item;
- (void)contactSearchDidCancel:(ContactSearchField*)searchField;
@end

@interface ContactSearchField : PNTextField

@property (nonatomic, assign) id<ContactSearchFieldDelegate> searchDelegate;
@property (nonatomic, readonly) UITableView* searchResultsTable;

- (void)clearResults;

@end
