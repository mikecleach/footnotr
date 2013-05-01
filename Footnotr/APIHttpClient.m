//
//  APIHttpClient.m
//  Footnotr
//
//  Created by Sam Homer on 4/30/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "APIHttpClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kFootnotrAPIBaseURLString = @"http://127.0.0.1:8000/";

@implementation APIHttpClient


+ (APIHttpClient *)sharedClient {
    static APIHttpClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIHttpClient alloc] initWithBaseURL:[NSURL URLWithString:kFootnotrAPIBaseURLString]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    
    // By default, the example ships with SSL pinning enabled for the app.net API pinned against the public key of adn.cer file included with the example. In order to make it easier for developers who are new to AFNetworking, SSL pinning is automatically disabled if the base URL has been changed. This will allow developers to hack around with the example, without getting tripped up by SSL pinning.
//    if ([[url scheme] isEqualToString:@"https"] && [[url host] isEqualToString:@"alpha-api.app.net"]) {
//        [self setDefaultSSLPinningMode:AFSSLPinningModePublicKey];
//    }
    
    return self;
}

@end
