//
//  CommentModel.m
//  Footnotr
//
//  Created by Sam Homer on 4/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "CommentModel.h"

@implementation CommentModel

- (void) addVote:(VoteModel *)voteToAdd
{
    NSError *error=nil;
    
    //if the vote model validates, add it to the array, else log error
    if([voteToAdd validate:&error]) {
        [self.votes addObject:voteToAdd];
    }
    else {
        NSLog([error description]);
    }
}

- (void) removeVote:(VoteModel *)voteToRemove
{
    [self.votes removeObjectIdenticalTo:voteToRemove];
}


-(BOOL) userDidVote:(UserModel *)user
{

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

- (BOOL)userDidCreate:(NSString *)username
{
    return [self.username isEqualToString:username];
}

@end
