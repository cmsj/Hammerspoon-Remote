//
//  HSRemoteHandler.m
//  Hammerspoon Remote
//
//  Created by Chris Jones on 23/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import "HSRemoteHandler.h"

NSString *SecCertificateRefFingerprint(SecCertificateRef certRef) {
    NSMutableString *output = [[NSMutableString alloc] init];
    CFDataRef data = SecCertificateCopyData(certRef);
    
    if (!data) {
        NSLog(@"ERROR: Unable to get certificate data to fingerprint");
        return nil;
    }
    
    unsigned char md5[CC_MD5_DIGEST_LENGTH+1];
    CC_MD5(CFDataGetBytePtr(data), (CC_LONG)CFDataGetLength(data), md5);
    md5[CC_MD5_DIGEST_LENGTH] = 0;
    
    for (unsigned int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5[i]];
    }
    
    CFRelease(data);
    return (NSString *)output;
}

NSString *SecIdentityRefFingerprint(SecIdentityRef identityRef) {
    NSString *output;
    SecCertificateRef certRef = nil;
    
    SecIdentityCopyCertificate(identityRef, &certRef);
    if (!certRef) {
        NSLog(@"ERROR: Unable to find certificate to get fingerprint");
        return nil;
    }
    
    output = SecCertificateRefFingerprint(certRef);
    CFRelease(certRef);
    
    return output;
}

@implementation HSRemoteHandler

- (void)setupPeerWithDisplayName:(NSString *)displayName {
    NSLog(@"setupPeerWithDisplayName: %@", displayName);
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    if (!self.peerID) {
        NSLog(@"ERROR: peerID is null");
        return;
    }
    NSError *certError;
    peerIdentity = MYGetOrCreateAnonymousIdentity([NSString stringWithFormat:@"Hammerspoon Remote: %@", displayName], 20 * kMYAnonymousIdentityDefaultExpirationInterval, &certError);
    if (!peerIdentity) {
        NSLog(@"ERROR: Unable to find/generate a certificate: %@", certError);
        return;
    }
    self.certMD5 = SecIdentityRefFingerprint(peerIdentity);
    NSLog(@"Generated/found my cert with fingerprint: %@", self.certMD5);
}

- (void)setupSession {
    NSLog(@"setupSession");
    self.session = [[MCSession alloc] initWithPeer:self.peerID securityIdentity:@[(__bridge id)peerIdentity] encryptionPreference:MCEncryptionRequired];
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
    NSLog(@"didChangeState: %li (%@)", (long)state, peerID.displayName);
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
    
    SecCertificateRef certRef = (__bridge SecCertificateRef)[certificate objectAtIndex:0];
    NSString *certMD5 = SecCertificateRefFingerprint(certRef);
    
    NSLog(@"Found a SHA1 of: %@", certMD5);

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Pairing attempt" message:[NSString stringWithFormat:@"Please check that the certificate fingerprints are the same on both devices:\n%@\n%@", certMD5, self.certMD5] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *pairAction = [UIAlertAction actionWithTitle:@"Pair" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {certificateHandler(YES);}];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {certificateHandler(NO);}];

    [alert addAction:pairAction];
    [alert addAction:cancelAction];
    
    [self.browser presentViewController:alert animated:YES completion:nil];
}

@end
