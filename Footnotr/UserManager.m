//
//  UserManager.m
//  Footnotr
//
//  Created by Sam Homer on 5/9/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "UserManager.h"

@implementation UserManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static UserManager *sharedUserManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUserManager = [[self alloc] init];
    });
    return sharedUserManager;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end
