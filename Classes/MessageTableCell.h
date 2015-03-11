//
//  ConverstaionTableViewCell.h
//  peanut
//
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.

#import <UIKit/UIKit.h>
#import "SkyMessage.h"
#import "Group.h"
#import "GroupViewController.h"
#import "ChatBubble.h"
#import "MetaMessageView.h"
#import "PillLabel.h"

#define kMessageTimeLabelHeight 20.0
#define kMessageNameLabelHeight 20.0
#define kMessageAttachmentLabelHeight 20.0

#define kConversationMessageTableAvatarHW       45.0
#define kConversationMessageTableDateHeight     20.0
#define kConversationMessageTableStatusHeight   20.0

extern const struct MarginSizes  {
    CGFloat small;
    CGFloat regular;
    CGFloat large;
} MarginSizes;

@class MessageTableCell;

@protocol MessageTableCellDelegate <NSObject>
@optional
- (void)didSelectAttachmentForCell:(MessageTableCell *)cell;
@end

@interface MessageTableCell : UITableViewCell

@property (nonatomic, weak) id<MessageTableCellDelegate> delegate;

@property (nonatomic, strong) PillLabel* timeLabel;
@property (nonatomic, strong) PNLabel* nameLabel; // <-- outside the chat bubble
@property (nonatomic, strong) PNLabel* attachmentLabel; // <-- outside the chat bubble
@property (nonatomic, strong) ChatBubble *chatBubble;
@property (nonatomic, strong) PNLabel *chatBubbleLabel;

@property (nonatomic, strong) SkyMessage* message;
@property (nonatomic, assign) BOOL showTimestamp;
@property (nonatomic, assign) BOOL showAvatar;

@property (nonatomic, strong) MetaMessageView* metaView;

+ (CGFloat) heightForMessage:(SkyMessage*) message
                withMaxWidth:(CGFloat) width
         andTimestampEnabled:(BOOL)enableTimestamp;

@end