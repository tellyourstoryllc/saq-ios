//
//  TextComposerViewController.m
//  SnapCracklePop
//
//  Created by Jim Young on 8/8/14.
//  Copyright (c) 2014 Perceptual Networks. All rights reserved.
//

#import "TextComposerViewController.h"
#import "Api.h"
#import "App.h"

#import "CalloutBubble.h"
#import "StatusView.h"

@interface TextComposerViewController () <UITextViewDelegate>

@property (nonatomic, strong) UIView* contentView;

@property (nonatomic, strong) CalloutBubble* bubble;
@property (nonatomic, strong) PNTextView* textView;

@property (nonatomic, strong) CalloutBubble* snapBubble;
@property (nonatomic, strong) PNTextView* snapTextView;

@property (nonatomic, strong) PNButton* exitButton;

@end

@implementation TextComposerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect b = self.view.bounds;
    self.view.backgroundColor = COLOR(blackColor);

    CGRect rect = CGRectMake(20, 100, b.size.width-40, 100);
    self.bubble = [[CalloutBubble alloc] initWithFrame:rect];
    self.bubble.bubbleColor = COLOR(orangeColor);
    self.bubble.calloutPosition = CalloutBubblePositionRight;
    self.bubble.calloutOffset = 20;
    [self.view addSubview:self.bubble];

    CGRect textRect = CGRectInset(self.bubble.frame, 10, 10);
    self.textView = [[PNTextView alloc] initWithFrame:textRect];
    self.textView.delegate = self;
    self.textView.font = FONT_B(38);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
    [self.view addSubview:self.textView];

    [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

    self.exitButton = [[PNButton alloc] initWithFrame:CGRectMake(0,0,40,40)];
    self.exitButton.buttonColor = COLOR(whiteColor);
    [self.exitButton maskWithImage:[UIImage imageNamed:@"x"] inverted:YES];
    [self.exitButton addTarget:self action:@selector(onExit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exitButton];

    // Phantom views to be used for snapchat image
    self.contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.contentView.backgroundColor = COLOR(blackColor);

    self.snapBubble = [[CalloutBubble alloc] initWithFrame:self.bubble.frame];
    self.snapBubble.bubbleColor = COLOR(blueColor);
    self.snapBubble.calloutPosition = CalloutBubblePositionLeft;
    self.snapBubble.calloutOffset = 20;
    [self.contentView addSubview:self.snapBubble];

    self.snapTextView = [[PNTextView alloc] initWithFrame:self.textView.frame];
    self.snapTextView.font = FONT_B(38);
    self.snapTextView.textColor = COLOR(whiteColor);
    self.snapTextView.backgroundColor = self.textView.backgroundColor;
    [self.contentView addSubview:self.snapTextView];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void) onExit {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {

    if (!range.length && !range.location && !string.length) {
        [self onExit];
        return NO;
    }

    switch ([string characterAtIndex:(string.length-1) ]) {
        case '\n':
        case '\r':
            [self sendPressed];
            [textView resignFirstResponder];
            return NO;
    }

    return [textView.text length] + [string length] - range.length <= 140;
}

- (void)sendPressed {
    NSString *text = [[NSString stringWithFormat:@"%@",self.textView.text] stringByTrimmingLeadingWhitespace];
    if(!text || text.length == 0)
        return;

    if([Api sharedApi].fayeConnected) {
        self.snapTextView.text = self.textView.text;
        [self.textView resignFirstResponder];
        [self sendMessageToApiWithText:text];
        self.textView.text = @"";
        [self onExit];
    } else {
        [StatusView showTitle:@"Please try again" message:@"Error communicating with server" completion:nil duration:2];
    }
}

-(void)sendMessageToApiWithText:(NSString*)text {

    if (!self.group)
        return;

    PNLOG(@"group.send_text");

    NSString *placeholder_id = [NSString randomStringOfLength:32];

    // Insert placeholder
    SkyMessage *message = [SkyMessage findOrCreateById:placeholder_id inContext:[App moc]];
    [message.managedObjectContext performBlockAndWait:^{
        message.is_placeholderValue = YES;
        message.text = text;
        message.group = self.group;
        message.user = [User me];
        message.created_at = [NSDate date];
        message.rankValue = self.group.last_message ? self.group.last_message.rankValue + 1 : 0;
        [message save];
        NSLog(@"placeholder: %@", message);
    }];

    // Params for API call:
    NSDictionary *ext = self.group.isOneToOneValue ? @{@"action" : @"create_one_to_one_message"} : nil;
    User* admin = [self.group.admins anyObject];
    NSString* channel = self.group.isOneToOneValue ? self.group.channel : admin.oneToOneGroup.channel;

    NSDictionary* metadata = @{@"placeholder":placeholder_id};
    NSString* metadataString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil]
                                                     encoding:NSUTF8StringEncoding];
    [[Api sharedApi] sendBackgroundMessage:@{
                                             @"text": text,
                                             @"client_metadata" : metadataString
                                             }
                                 onChannel:channel
                                   withExt:ext];

}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.textView) {
        [self adjustBubbleSize];
    }
}

- (void)adjustBubbleSize {
    PNTextView* tv = self.textView;
    CGRect v = self.view.frameMinusKeyboard;
    CGFloat minHeight = 60;
    CGFloat maxHeight = self.view.frame.size.height - 40;

    CGFloat height = MAX(minHeight, tv.contentSize.height);
    height = MIN(maxHeight, height);
    self.textView.frame = CGRectMake(0, 0, tv.frame.size.width, height);
    self.bubble.frame = CGRectSetTopCenter(v.size.width/2, 60, CGRectInset(tv.frame, -10, -10));
    self.textView.center = self.bubble.center;

    self.snapBubble.frame = self.bubble.frame;
    self.snapTextView.frame = CGRectOffset(self.textView.frame, 5, 0);
}

- (BOOL) prefersStatusBarHidden { return YES; }

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)dealloc {
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
}

@end
