//
//  CommentModel.h
//  Footnotr
//
//  Created by Sam Homer on 4/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "JSONModel.h"
#import "VoteModel.h"

@protocol CommentModel

@end

@interface CommentModel : JSONModel

@property (strong,nonatomic) NSString *username;
@property (strong,nonatomic) NSString *comment;
@property (strong, nonatomic) NSMutableArray<VoteModel> *votes;
@property int pk;

- (void) addVote:(VoteModel *)voteToAdd;

- (void) removeVote:(VoteModel *)voteToRemove;

- (BOOL) userDidVote:(UserModel *)user;

- (VoteModel *) getVoteForUser:(UserModel *)user;

- (BOOL)userDidCreate:(NSString *)username;

@end
