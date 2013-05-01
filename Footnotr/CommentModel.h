//
//  CommentModel.h
//  Footnotr
//
//  Created by Sam Homer on 4/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "JSONModel.h"

@protocol CommentModel

@end

@interface CommentModel : JSONModel

@property (strong,nonatomic) NSString *user;
@property (strong,nonatomic) NSString *comment;
@property int votes;
@property (strong, nonatomic) NSString *url;

@end
