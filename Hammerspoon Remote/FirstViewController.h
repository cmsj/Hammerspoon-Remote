//
//  FirstViewController.h
//  Hammerspoon Remote
//
//  Created by Chris Jones on 23/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface FirstViewController : UIViewController <MCBrowserViewControllerDelegate>
@property (strong, nonatomic) AppDelegate *appDelegate;

- (IBAction)searchForPlayers:(id)sender;

@end

