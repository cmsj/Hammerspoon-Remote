//
//  HSRemoteTrustStore.h
//  Hammerspoon Remote
//
//  Created by Chris Jones on 29/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSRemoteTrustStore : NSObject {
    NSUserDefaults *store;
}

+ (id)sharedInstance;
- (void)trustPeer:(NSString *)peerName withCert:(SecCertificateRef)certificate;
- (BOOL)isPeerTrusted:(NSString *)peerName forCert:(SecCertificateRef)certificate;
@end
