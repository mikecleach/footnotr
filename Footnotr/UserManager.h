//
//  UserManager.h
//  Footnotr
//
//  Created by Sam Homer on 5/9/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@interface UserManager : NSObject

@property (strong, nonatomic) UserModel *loggedInUser;

+ (id)sharedManager;

@end
