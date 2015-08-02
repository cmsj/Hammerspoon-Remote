//
//  HSRemoteTrustStore.m
//  Hammerspoon Remote
//
//  Created by Chris Jones on 29/07/2015.
//  Copyright (c) 2015 Hammerspoon. All rights reserved.
//

#import "HSRemoteTrustStore.h"

@implementation HSRemoteTrustStore

+ (HSRemoteTrustStore *)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        store = [[NSUserDefaults alloc] initWithSuiteName:@"group.org.hammerspoon.Remote"];
        [store registerDefaults:@{@"trustedPeers":@{}}];
    }
    return self;
}

- (void)trustPeer:(NSString *)peerName withCert:(SecCertificateRef)certificate {
    NSMutableDictionary *trustedPeers = [[store dictionaryForKey:@"trustedPeers"] mutableCopy];
    [trustedPeers setObject:(__bridge id)certificate forKey:peerName];
    [store setObject:trustedPeers forKey:@"trustedPeers"];
    [store synchronize];
}

- (BOOL)isPeerTrusted:(NSString *)peerName forCert:(SecCertificateRef)certificate {
    NSDictionary *trustedPeers = [store dictionaryForKey:@"trustedPeers"];
    return ([trustedPeers objectForKey:peerName] == (__bridge id)(certificate));
}

@end
