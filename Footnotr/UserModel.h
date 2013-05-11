//
//  UserModel.h
//  Footnotr
//
//  Created by Sam Homer on 5/9/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "JSONModel.h"

@interface UserModel : JSONModel

@property int pk;
@property (strong, nonatomic) NSString *username;

@end
