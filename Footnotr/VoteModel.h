//
//  VoteModel.h
//  Footnotr
//
//  Created by Sam Homer on 5/7/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "UserModel.h"

@protocol VoteModel

@end

@interface VoteModel : JSONModel

@property (strong, nonatomic) UserModel *user;
//@property int comment;
@property int pk;
@property (strong, nonatomic) NSString *username;


@end
