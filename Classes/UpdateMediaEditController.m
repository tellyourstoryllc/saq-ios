//
//  UpdateMediaEditController.m
//  NoMe
//
//  Created by Jim Young on 1/16/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "UpdateMediaEditController.h"
#import "Api.h"
#import "SavedApiRequest.h"

@interface UpdateMediaEditController ()

@end

@implementation UpdateMediaEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    self.view.backgroundColor = COLOR(blackColor);

    self.saveButton = [[ArrowButton alloc] initWithFrame:CGRectZero];
    self.saveButton.arrowColor = COLOR(greenColor);
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSave)]];
    [self.view addSubview:self.saveButton];

    self.cancelButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.cancelButton.buttonColor = COLOR(darkGrayColor);
    [self.cancelButton setImage:[UIImage tintedImageNamed:@"x" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    [self.cancelButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel)]];
    [self.view addSubview:self.cancelButton];

    self.clearOverlayButton = [[PNButton alloc] initWithFrame:CGRectZero];
    self.clearOverlayButton.buttonColor = COLOR(darkGrayColor);
    [self.clearOverlayButton setImage:[UIImage tintedImageNamed:@"eraser" color:COLOR(whiteColor)] forState:UIControlStateNormal];
    [self.clearOverlayButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClearOverlay)]];
    [self.view addSubview:self.clearOverlayButton];

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b = self.view.bounds;
    CGRect noKeyboardFrame = [self.view frameMinusKeyboard];

    self.saveButton.frame = CGRectSetBottomRight(b.size.width-10, noKeyboardFrame.size.height-10, CGRectMake(0,0,80,50));
    self.saveButton.rightArrowWidth = 15;
    self.saveButton.leftArrowWidth = -15;

    self.cancelButton.frame = CGRectMake(10,10,50,50);
    self.clearOverlayButton.frame = CGRectSetOrigin(CGRectGetMaxX(self.cancelButton.frame)+10,
                                                    CGRectGetMinY(self.cancelButton.frame),
                                                    CGRectMake(0, 0, 50, 50));
}

- (void)setSnap:(SkyMessage *)snap
{
    _snap = snap;
    [snap fetchMediaWithCompletion:^(UIImage *photo, NSURL *videoUrl, UIImage *overlay) {
        self.photo = photo;
        self.videoUrl = videoUrl;
        self.graffitiView.overlay = overlay;
        self.clearOverlayButton.hidden = (overlay == nil);
    }];
}

- (void)onClearOverlay
{
    [self.graffitiView clear];
    self.clearOverlayButton.hidden = YES;
}

- (void)onSave
{

    if (self.graffitiView.hasEdits) {

        NSData* overlayData = UIImagePNGRepresentation(self.artwork);
        NSString* overlayText = self.graffitiView.textString ?: @"";

        SavedApiRequest* existingRequest;

        if (self.snap.is_placeholderValue) {
            for (SavedApiRequest* request in self.snap.saved_requests) {
                if ([request.data2_param isEqualToString:@"attachment_overlay_file"] && request.statusValue == MediaUploadStatusPending) {
                    existingRequest = request;
                    break;
                }
            }

        }

        if (existingRequest) {
            NSMutableDictionary* params = [[NSJSONSerialization JSONObjectWithData:existingRequest.jsonData
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil] mutableCopy];
            params[@"attachment_overlay_text"] = overlayText;
            [overlayData writeToFile:existingRequest.data2_filepath atomically:YES];
            [existingRequest save];
        }
        else {

            NSMutableDictionary* params = [@{@"attachment_overlay_text":overlayText} mutableCopy];
            SavedApiRequest* update = [SavedApiRequest storeRequestWithPath:[NSString stringWithFormat:@"/stories/%@/update", self.snap.id]
                                                                 parameters:params
                                                                       data:overlayData
                                                                  dataParam:@"attachment_overlay_file"
                                                               dataMimeType:@"image/png"];

            AFHTTPRequestOperation* uploadOperation = [update requestOperationWithCallback:^(NSData *data, NSHTTPURLResponse *response, id result, NSSet *entities, NSError *error) {
                NSLog(@"%@", data);
            }];

            [[Api slowApi] enqueueOperation:uploadOperation];

            NSString* cacheKey = [NSString stringWithFormat:@"%f.png",(double)[[NSDate date] timeIntervalSince1970]];
            [[SnapCache shared] setData:overlayData forKey:cacheKey];
            self.snap.attachment_local_overlay_url = [[[SnapCache shared] urlForKey:cacheKey] absoluteString];
            self.snap.updated_at = [NSDate date];
            [self.snap save];
        }
    }

    [self.navigationController popViewControllerAnimated:NO] ?: [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)onCancel
{
    void (^dismissBlock)() = ^() {
        [self.navigationController popViewControllerAnimated:NO] ?: [self dismissViewControllerAnimated:NO completion:nil];
    };

    if (self.graffitiView.hasEdits) {
        [PNUIAlertView showWithTitle:@"Discard changes"
                             message:nil
                             buttons:@[@"Keep editing", @"Discard changes"]
                      withCompletion:^(NSInteger buttonIndex) {
                          if (buttonIndex == 1)
                              dismissBlock();
                      }];
    }
    else {
        dismissBlock();
    }
}

- (void)didEndEditing {
    [super didEndEditing];
    self.clearOverlayButton.hidden = !self.graffitiView.hasEdits;
}

- (void)didEndTexting {
    [super didEndTexting];
    self.clearOverlayButton.hidden = !self.graffitiView.hasEdits;
}

- (void)didEndDrawing {
    [super didEndDrawing];
    self.clearOverlayButton.hidden = !self.graffitiView.hasEdits;
}

@end
