//
//  HSRemoteHandler.m
//  Hammerspoon Remote
//
//  Created by Chris Jones on 23/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import "HSRemoteHandler.h"

NSString *SecIdentityRefFingerprint(SecIdentityRef identityRef) {
    NSMutableString *output;
    SecCertificateRef certRef;
    
    SecIdentityCopyCertificate(identityRef, &certRef);
    CFDataRef data = SecCertificateCopyData(certRef);
    
    unsigned char sha1[CC_SHA1_DIGEST_LENGTH+1];
    CC_SHA1(CFDataGetBytePtr(data), (CC_LONG)CFDataGetLength(data), sha1);
    sha1[CC_SHA1_DIGEST_LENGTH] = 0;
    
    for (unsigned int i = 0; i < (unsigned int)CFDataGetLength(data); i++) {
        [output appendFormat:@"%02x", sha1[i]];
    }
    
    CFRelease(certRef);
    CFRelease(data);
    
    return (NSString *)output;
}

@implementation HSRemoteHandler

- (void)setupPeerWithDisplayName:(NSString *)displayName {
    NSLog(@"setupPeerWithDisplayName: %@", displayName);
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
}

- (void)setupSession {
    NSLog(@"setupSession");
    self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:nil encryptionPreference:MCEncryptionRequired];
    self.session.delegate = self;
}

- (void)setupBrowser {
    NSLog(@"setupBrowser");
    self.browser = [[MCBrowserViewController alloc] initWithServiceType:@"hmspn-remoteapp" session:self.session];
    self.browser.maximumNumberOfPeers = 2;
    self.browser.minimumNumberOfPeers = 2;
    //[self advertiseSelf:YES];
}

- (void)advertiseSelf:(BOOL)advertise {
    NSLog(@"advertiseSelf: %@", advertise?@"YES":@"NO");
    if (advertise) {
        self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"hmspn-remoteapp" discoveryInfo:nil session:self.session];
        [self.advertiser start];
        
    } else {
        [self.advertiser stop];
        self.advertiser = nil;
    }
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"didChangeState: %li", (long)state);
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler {
    NSLog(@"didReceiveCertificate");
    if (!certificate) {
        NSLog(@"No certificate received. Refusing to pair");
        certificateHandler(NO);
        return;
    }
    
    SecIdentityRef identityRef = (__bridge SecIdentityRef)[certificate objectAtIndex:0];
    
    NSLog(@"Found a SHA1 of: %@", SecIdentityRefFingerprint(identityRef));

    certificateHandler(YES);
}

@end
