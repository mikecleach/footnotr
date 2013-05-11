//
//  CommentModel.m
//  Footnotr
//
//  Created by Sam Homer on 4/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel


-(BOOL) userDidVote:(UserModel *)user
{
    //FIXME:check actual username. Using hardcoded value for now
    NSPredicate *userMatchPredicate = [NSPredicate predicateWithFormat:@"user.pk == %d", user.pk];
    
    NSArray *matchingArray = [self.votes filteredArrayUsingPredicate:userMatchPredicate];
    
    return matchingArray.count == 1;
    
}

//be sure a vote for a particular user exists before using this...
-(VoteModel *) getVoteForUser:(UserModel *)user
{

    NSPredicate *userMatchPredicate = [NSPredicate predicateWithFormat:@"user.pk == %d", user.pk];
    
    NSArray *matchingArray = [self.votes filteredArrayUsingPredicate:userMatchPredicate];
    
    return (VoteModel *)[matchingArray objectAtIndex:0];
    
}

@end
