//
//  FeedbackSettingsCell.m
//  groups
//
//  Created by Jim Young on 12/11/13.
//  Copyright (c) 2013 Perceptual Networks. All rights reserved.
//

#import "InfoSettingsCell.h"

#import "User.h"
#import "App.h"
#import "AlertView.h"
#import "PNMailComposeViewController.h"
#import "WebViewController.h"

@interface InfoSettingsCell()
@property (nonatomic, strong) PNButton* infoButton;
@property (nonatomic, strong) PNButton* feedbackButton;
@end

@implementation InfoSettingsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        __weak InfoSettingsCell* weakSelf = self;

        self.infoButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,110,40)];
        [self.infoButton setTitle:@"Legal Info" forState:UIControlStateNormal];
        [self.infoButton setBorderWithColor:COLOR(grayColor) width:1.0];
        self.infoButton.buttonColor = [UIColor clearColor];
        self.infoButton.titleLabel.font = FONT(11);
        [self.infoButton setTitleColor:COLOR(grayColor) forState:UIControlStateNormal];

        [self addChild:self.infoButton];
        [self.infoButton setTappedBlock:^{
            UINavigationController *nav = [WebViewController controllerInNavigationControllerWithURL:[NSURL URLWithString:kTermsOfServiceURL]];
            [weakSelf.controller presentViewController:nav animated:YES completion:^{
                PNLOG(@"terms_of_service.show");
            }];
        }];

        self.feedbackButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,140,40)];
        [self.feedbackButton setTitle:@"Send Feedback" forState:UIControlStateNormal];
        [self.feedbackButton setBorderWithColor:COLOR(greenColor) width:1.0];
        self.feedbackButton.buttonColor = [UIColor clearColor];
        self.feedbackButton.titleLabel.font = FONT(14);
        [self.feedbackButton setTitleColor:COLOR(greenColor) forState:UIControlStateNormal];

        [self addChild:self.feedbackButton];
        [self.feedbackButton setTappedBlock:^{
            PNMailComposeViewController* mcv = [[PNMailComposeViewController alloc] init];
            [mcv setSubject:[NSString stringWithFormat:@"Feedback from %@", [[User me] name]]];
            [mcv setMessageBody:[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n____________________________\n%@ (%@)\niOS %@ (build %@)", [App username], [App userId], [[UIDevice currentDevice] systemVersion], [PNSupport version]] isHTML:NO];
            [mcv setToRecipients:@[kSupportEmail]];
            if (mcv) {
                [weakSelf.controller presentViewController:mcv animated:YES completion:^{
                    PNLOG(@"feedback.email.show");
                }];
            }
        }];


        self.paddingY = 0;
        [self sizeToFit];
    }
    return self;
}

- (void)layoutSubviews {
    self.infoButton.frame = CGRectSetOrigin(20, 0, self.infoButton.frame);
    self.feedbackButton.frame = CGRectSetTopRight(self.bounds.size.width-20, 0, self.feedbackButton.frame);
    [super layoutSubviews];
}

@end
