//
//  MessageCollectionCell.h
//  NoMe
//
//  Created by Jim Young on 1/12/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "Group.h"
#import "Story.h"
#import "SnapCardView.h"
#import "SnapCollectionCell.h"

@class MessageCollectionCell;

@protocol MessageCollectionCellDelegate <NSObject>

- (void)messageCell:(MessageCollectionCell*)cell didOpen:(Group*)group;
- (void)messageCell:(MessageCollectionCell*)cell didClear:(Group*)group;

@end

@interface MessageCollectionCell : SnapCollectionCell

@property (nonatomic, strong) Group* group;
@property (nonatomic, strong) SkyMessage* snap;
@property (nonatomic, weak) id<MessageCollectionCellDelegate> delegate;

@end
