//
//  AddStoryCollectionCell.m
//  SnapCracklePop
//
//  Created by Jim Young on 10/13/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "AddStoryCollectionCell.h"
#import "PNUserPreferences.h"
#import "PNMonochromeFilter.h"

@interface AddStoryCollectionCell()
@property (nonatomic, strong) PNLabel* plusLabel;
@property (nonatomic, strong) PNLabel* label;
@end

@implementation AddStoryCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = COLOR(whiteColor);

        self.plusLabel = [[PNLabel alloc] initWithFrame:self.contentView.bounds];
        self.plusLabel.textAlignment = NSTextAlignmentCenter;
        self.plusLabel.font = [[Theme current] extraBoldFontWithSize:142];
        self.plusLabel.textColor = [COLOR(blackColor) colorWithAlphaComponent:0.88];
        self.plusLabel.text = @"+";
        [self.contentView addSubview:self.plusLabel];

        self.label = [PNLabel labelWithText:@"Add Your Story" andFont:FONT_B(12)];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.frame = CGRectSetBottomCenter(self.bounds.size.width/2, self.bounds.size.height-2, self.label.frame);
        [self.contentView addSubview:self.label];
    }
    return self;
}

@end
