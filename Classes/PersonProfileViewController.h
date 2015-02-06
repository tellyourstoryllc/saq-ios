//
//  PersonProfileViewController.h
//  NoMe
//
//  Created by Jim Young on 1/20/15.
//  Copyright (c) 2015 Perceptual Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol PersonProfileDelegate <NSObject>

@optional
- (void)profileDidSelectMessage:(User*)user;

@end

@interface PersonProfileViewController : UIViewController

@property (nonatomic, strong) User* user;
@property (nonatomic, assign) id<PersonProfileDelegate> delegate;

@end
