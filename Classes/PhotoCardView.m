//
//  TinderPhotoView.m
//  SnapCracklePop
//
//  Created by Jim Young on 8/1/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "PhotoCardView.h"
#import "PNCircularProgressView.h"
#import "Story.h"
#import "TutorialBubble.h"

@interface PhotoCardView()

@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIImageView* overlayView;
@property (nonatomic, strong) PNCircularProgressView* circleProgress;

@property (nonatomic, strong) TutorialBubble* replyTutorial;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation PhotoCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect b = self.bounds;

        self.backgroundColor = COLOR(darkGrayColor);

        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];

        self.overlayView = [[UIImageView alloc] initWithFrame:b];
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.overlayView.userInteractionEnabled = NO;
        [self addSubview:self.overlayView];

        self.circleProgress = [[PNCircularProgressView alloc] initWithFrame:CGRectMake(0,0,b.size.width/3,b.size.width/3)];
        self.circleProgress.lineWidth = 3;
        self.circleProgress.tintColor = COLOR(grayColor);
        [self addSubview:self.circleProgress];

        [self hideControls];

    }
    return self;
}

- (void)layoutSubviews {
    CGRect b = self.bounds;
    self.imageView.frame = b;
    self.overlayView.frame = b;

    self.circleProgress.frame = CGRectMake(0,0,b.size.width/3,b.size.width/3);
    self.circleProgress.center = self.center;
}

- (void)setMessage:(SkyMessage *)message {
    if (self.message == message)
        return;

    [self.message cancelMediaFetch];
    [super setMessage:message];

    self.photo = nil;
    self.overlayView.image = nil;
    self.imageView.image = nil;
    self.isLoading = NO;
    [self hideControls];
}

- (void)loadContentWithCompletion:(void (^)())completion {

    void (^finishBlock)() = ^() {
        if ([self.snapCard.delegate respondsToSelector:@selector(card:didLoadContent:)]) {
            [self.snapCard.delegate card:self.snapCard didLoadContent:self.message];
        }
        if (completion) completion();
    };

    if (self.photo) {
        finishBlock();
        return;
    }

    // This hack prevents progress indicator from showing if media is fetched quickly (i.e., from local cache)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isLoading) {
            self.circleProgress.hidden = NO;
            self.circleProgress.frame = CGRectMake(0,0,self.bounds.size.width/3,self.bounds.size.width/3);
            self.circleProgress.center = self.center;
            [self.circleProgress startSpinProgressBackgroundLayer];
        }
    });

    __block SkyMessage* loadingMessage = self.message;

    void (^loadBlock)(UIImage*, UIImage*) = ^(UIImage* photo, UIImage* overlay) {
        on_main(^{
            self.circleProgress.hidden = YES;
            [self.circleProgress stopSpinProgressBackgroundLayer];

            if (loadingMessage == self.message) {
                self.photo = photo;
                self.imageView.image = photo;
                self.overlayView.image = overlay;
            }

            // If aspect similar of image is similar to that of screen, force fill.
            if (ABS(photo.size.height/photo.size.width - self.bounds.size.height/self.bounds.size.width) < 0.2)
                self.imageView.contentMode = UIViewContentModeScaleAspectFill;
            else
                self.imageView.contentMode = self.contentMode;

            finishBlock();
        });
    };

    [self.message fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *overlay) {
        loadBlock(photo, overlay);
    }];
}

- (void)updateOrientation {

//    CGRect b = self.bounds;
//
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    if (orientation == UIDeviceOrientationLandscapeLeft) {
//        self.imageView.frame = CGRectMake(0, 0, b.size.height+2, b.size.width+2);
//        self.imageView.center = self.center;
//        self.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI_2);
//    }
//    else if (orientation == UIDeviceOrientationLandscapeRight) {
//        self.imageView.frame = CGRectMake(0, 0, b.size.height+2, b.size.width+2);
//        self.imageView.center = self.center;
//        self.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
//    }
//    else {
//        self.imageView.transform = CGAffineTransformIdentity;
//        self.imageView.frame = self.bounds;
//    }

}

- (void)didAppear {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateOrientation)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)didDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)messageWasUpdated {
    self.photo = nil;
    [self loadContentWithCompletion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end