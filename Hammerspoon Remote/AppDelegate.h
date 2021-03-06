//
//  AppDelegate.h
//  Hammerspoon Remote
//
//  Created by Chris Jones on 23/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSRemoteHandler.h"

@class HSRemoteHandler;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) HSRemoteHandler *remoteHandler;

@property (nonatomic, retain) IBOutlet UIViewController *firstViewController;

@end

