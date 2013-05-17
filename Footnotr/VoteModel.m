//
//  VoteModel.m
//  Footnotr
//
//  Created by Sam Homer on 5/7/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "VoteModel.h"

@implementation VoteModel



- (BOOL) validate:(NSError *__autoreleasing *)error
{
    if (self.pk == 0) {
        
        *error = [NSError errorWithDomain:@"validation" code:1 userInfo:[NSDictionary dictionaryWithObject:@"Model failed Validation - pk is 0" forKey:NSLocalizedDescriptionKey]];
        
        return NO;
    }
    
    return YES;
}

@end
