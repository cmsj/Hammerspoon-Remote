//
//  FirstViewController.m
//  Hammerspoon Remote
//
//  Created by Chris Jones on 23/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.appDelegate.remoteHandler setupPeerWithDisplayName:[UIDevice currentDevice].name];
    [self.appDelegate.remoteHandler setupSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchForPlayers:(id)sender {
    if (self.appDelegate.remoteHandler.session != nil) {
        [[self.appDelegate remoteHandler] setupBrowser];
        [[[self.appDelegate remoteHandler] browser] setDelegate:self];
        
        [self presentViewController:self.appDelegate.remoteHandler.browser
                           animated:YES
                         completion:nil];
        NSLog(@"presented Browser");
    }
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.remoteHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self.appDelegate.remoteHandler.browser dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info {
    NSLog(@"shouldPresentNearbyPeer: %@", peerID.displayName);
    return YES;
}

@end
