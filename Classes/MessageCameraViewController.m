//
//  MessageCameraViewController.m
//  NoMe
//
//  Created by Jim Young on 1/27/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import "MessageCameraViewController.h"
#import "MessageCamera.h"

@interface MessageCameraViewController ()<PNCameraDelegate>

@property (nonatomic, strong) MessageCamera* camera;

@end

@implementation MessageCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.camera = [[MessageCamera alloc] initWithFrame:self.view.bounds];
    self.camera.delegate = self;
    [self.view addSubview:self.camera];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.camera startPreview];
}

- (void)onImport {
    NSLog(@"IMPRTTT?");
}

- (void)camera:(id)recorder didRecord:(NSURL*)videoUrl
{
    PNCamera* camera = (PNCamera*)recorder;
    camera.player.muted = YES;
    camera.player.backgroundColor = COLOR(darkGrayColor);
    camera.player.screenshot = camera.snapshot;
    [camera startVideoPlayback];
    [camera stopPreview];
}

- (void)camera:(PNCamera*)camera publishedImage:(UIImage*)image andVideo:(NSURL*)videoUrl withParams:(NSDictionary*)params
{
    NSMutableDictionary* newParams = [NSMutableDictionary new];
    if (params) [newParams addEntriesFromDictionary:params];
    newParams[@"source"] = @"camera";

    [Group publishVideo:videoUrl orImage:image withOverlay:nil
               toGroups:@[self.group]
                 params:newParams
             completion:^(BOOL success, BOOL cancelled, NSSet *entities) {
             }];

    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:NO];
    else
        [self dismissViewControllerAnimated:NO completion:nil];

}

- (void)cameraDidCancel:(PNCamera*)camera
{
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:NO];
    else
        [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)cameraDidFailToRecord:(PNCamera*)camera
{
}

- (void)cameraDidShutoff:(PNCamera*)camera
{
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
