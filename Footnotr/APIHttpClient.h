//
//  APIHttpClient.h
//  Footnotr
//
//  Created by Sam Homer on 4/30/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"
    
@interface APIHttpClient : AFHTTPClient

+ (APIHttpClient *)sharedClient;


@end
