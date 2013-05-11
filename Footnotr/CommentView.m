//
//  CommentView.m
//  Footnotr
//
//  Created by Sam Homer on 5/1/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "CommentView.h"
#import "APIHttpClient.h"
#import "UserManager.h"

#define ROW_HEIGHT 48

@implementation CommentView


- (id)initWithComment:(CommentModel *)comment andFrame:(CGRect)frame
{
    self.comment = comment;
    
    return [self initWithFrame:frame];
    

    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setup
{
    [super setup];
    
    //get the current user
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    
    
    //setting up standard style elements
    UIEdgeInsets standardMarginOrPadding = UIEdgeInsetsMake(0, 8, 0, 8);
    
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    //Votes label creation
    self.votesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.votesLabel.text = [NSString stringWithFormat:@"Votes: %d", self.comment.votes.count];
    self.votesLabel.size = [self.votesLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    
    
    //vote for this comment button creation
    self.voteBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT)];
    
    // Set the background for any states you plan to use
    [self.voteBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.voteBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.voteBtn setTitle:@"+1" forState:UIControlStateNormal];
    [self.voteBtn setTitle:@"+1" forState:UIControlStateHighlighted];
    self.voteBtn.margin = standardMarginOrPadding;
    
    self.voteBtn.highlighted = [self.comment userDidVote:loggedInUser];
    
    
    [self.voteBtn onControlEvent:UIControlEventTouchUpInside do:^{
        

        
        void (^addingVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
           
            VoteModel *createdVote = [[VoteModel alloc] init];
            createdVote.user = loggedInUser;
            createdVote.pk = [[JSON objectForKey:@"pk"] intValue];
            createdVote.username = [JSON objectForKey:@"username"];
           
            [self.comment.votes addObject:createdVote];
           
           
            self.voteBtn.highlighted = [self.comment userDidVote:loggedInUser];

            self.votesLabel.text = [NSString stringWithFormat:@"Votes: %d", self.comment.votes.count];

        };
        
        void (^deleteVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
            
            //TODO:what if delete fails? need to handle it

            
            VoteModel *deletedVote = [self.comment getVoteForUser:loggedInUser];
            
            [self.comment.votes removeObject:deletedVote];
            
            self.voteBtn.highlighted = [self.comment userDidVote:loggedInUser];
            
            self.votesLabel.text = [NSString stringWithFormat:@"Votes: %d", self.comment.votes.count];
            
        };
        
        
        APIHttpClient *sharedClient = [APIHttpClient sharedClient];
        //TODO:hardcoding all up in here
        //if already voted, delete that vote. Otherwise add vote
        if([self.comment userDidVote:loggedInUser]) {
            
            
            
            NSString *path = [NSString stringWithFormat:@"votes/%d/", [self.comment getVoteForUser:loggedInUser].pk];
                      
            [sharedClient deletePath:path parameters:nil success:deleteVoteBlock failure:nil];
        }
        else {
            
            NSMutableDictionary *newVote = [[NSMutableDictionary alloc] init];
            [newVote setObject:[NSString stringWithFormat:@"%d", self.comment.pk] forKey:@"comment"];
            [newVote setObject:[NSString stringWithFormat:@"%d", loggedInUser.pk] forKey:@"user"];
            
            
            NSString *path = @"votes/new";
            [sharedClient postPath:path parameters:newVote success:addingVoteBlock failure:nil];
        }
        
        NSLog(@"tapped");
    }];
    
    
//    [sharedClient patchPath:path parameters:commentDict success:^(AFHTTPRequestOperation *operation, id JSON) {
//        
//        //TODO:what if put fails? need to handle it
//        NSError *error;
//        CommentModel *updatedComment = [[CommentModel alloc] initWithDictionary:JSON error:&error];
//        
//        //TODO:figure out if it's dangerous to only update the local comment here. OK because server responses are very often?
//        self.comment = updatedComment;
//        
//        self.voteBtn.highlighted = [self.comment userDidVote:@""];
//        
//        self.votesLabel.text = [NSString stringWithFormat:@"Votes: %d", self.comment.votes.count];
//        
//    }
//     //TODO:Add failure handling
//                    failure:nil];
//    
    
    
    //edit comment button
    self.editBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT)];
    
    // Set the background for any states you plan to use
    [self.editBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.editBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.editBtn setTitle:@"Edit" forState:UIControlStateNormal];
    self.editBtn.margin = standardMarginOrPadding;
    
    
    self.deleteBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT)];
    
    // Set the background for any states you plan to use
    [self.deleteBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.deleteBtn setTitle:@"Del" forState:UIControlStateNormal];
    self.deleteBtn.margin = standardMarginOrPadding;
    
    

    NSMutableArray *voteItems = [[NSMutableArray alloc] init];
    [voteItems addObject:self.votesLabel];
    [voteItems addObject:self.voteBtn];
    
    NSMutableArray *commentModItems = [[NSMutableArray alloc] init];
    [commentModItems addObject:self.editBtn];
    [commentModItems addObject:self.deleteBtn];
    
    self.commentDetails = [MGLine lineWithLeft:self.comment.username right:commentModItems size:CGSizeMake(360, 36)];
    
    self.commentDetails.middleItems = voteItems;
    
    
    //create comment content line
    self.commentContent = [MGLine multilineWithText:self.comment.comment font:nil width:self.size.width padding:UIEdgeInsetsMake(16, 16, 16, 16)];
    
    
    //setup comment container box
    self.layer.cornerRadius = 4;
    self.borderStyle = MGBorderEtchedAll;
    
    //add lines to box
    [self.boxes addObject:self.commentDetails];
    [self.boxes addObject:self.commentContent];
    
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
