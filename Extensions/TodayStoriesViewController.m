//
//  TodayViewController.m
//  Recent Stories
//
//  Created by Jim Young on 10/24/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "TodayStoriesViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "ExtensionConduit.h"
#import "NSArray+Map.h"
#import "VideoURLView.h"

@interface TodayStoriesViewController()
@property (nonatomic,strong) NSMutableArray* properties;
@end

@implementation TodayStoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.properties = [NSMutableArray new];
    for (int x=0; x < 3; x++) {
        [self.properties addObject:@{}];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self expandAllSubviews:self.cardLeft];
    [self expandAllSubviews:self.cardMiddle];
    [self expandAllSubviews:self.cardRight];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {

    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    NSLog(@"start updating storiez");

    BOOL didUpdate = NO;

    NSArray* cards = @[self.cardLeft, self.cardMiddle, self.cardRight];
    NSArray* labels = @[self.labelLeft, self.labelMiddle, self.labelRight];

    ExtensionConduit* cache = [ExtensionConduit shared];
    [cache reloadCacheInfo];

    NSArray* snaps = [cache.allStories copy];

    if (snaps.count == 0) {
        self.labelLeft.text = @"No stories";
    }

    int x=snaps.count-1;
    int y=0;

    while (x >= 0 && y < cards.count) {

        ExtensionConduitItem* item = snaps[x];
        if (![self alreadyDisplayingItem:item atIndex:y]) {
            didUpdate = YES;

            [self.properties setObject:item.properties atIndexedSubscript:y];

            if (item) {
                UIView* card = (UIView*)cards[y];
                UILabel* label = (UILabel*)labels[y];
                [self removeAllSubviews:card];

                if (item.image) {
                    UIImageView* imageView = [[UIImageView alloc] initWithImage:item.image];
                    imageView.frame = [card bounds];
                    [card addSubview:imageView];
                    label.text = item.properties[@"username"];
                    y++;
                }
                else if (item.videoUrl) {
                    VideoURLView* videoView = [[VideoURLView alloc] initWithFrame:card.bounds];
                    videoView.videoUrl = item.videoUrl;
                    videoView.muted = YES;
                    [card addSubview:videoView];
                    label.text = item.properties[@"username"];
                    [videoView play];
                    y++;
                }
            }
        }
        else {
            NSLog(@"already showing story: %@", item.properties);
            y++;
        }
        x--;
    }

    // Set "cookie"
    [cache setObject:[NSDate date] forKey:@"story_widget_updated_at"];

    if (didUpdate) {
        NSLog(@"done storieez new data");
        completionHandler(NCUpdateResultNewData);
    }
    else {
        NSLog(@"done storieez NO new data");
        completionHandler(NCUpdateResultNoData);
    }
}

- (void)onTouch:(id)sender {
    NSString* urlString = [NSString stringWithFormat:@"%@://feed/src/widget", kCustomURLScheme];

    [self.extensionContext openURL:[NSURL URLWithString:urlString]
                 completionHandler:^(BOOL success) {
                     //
                 }];
}

- (BOOL)alreadyDisplayingItem:(ExtensionConduitItem*)item atIndex:(NSUInteger)index {
    NSString* itemId = item.properties[@"story_id"];
    NSString* existingId = self.properties[index][@"story_id"];
    return [existingId isEqualToString:itemId];
}

@end
