//
//  CommentView.m
//  Footnotr
//
//  Created by Sam Homer on 5/1/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "CommentView.h"


#define ROW_HEIGHT 48

@implementation CommentView


- (id)initWithComment:(NSString *)commentText andUsername:(NSString *)username andVoteCount:(int)voteCount andFrame:(CGRect)frame
{

    self.commentText = commentText;
    self.username = username;
    [self setVoteCount:voteCount];
    
    
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

- (void)setVoteCount:(int)voteCount
{
    self.votes = voteCount;
    [self.votesLabel setText:[NSString stringWithFormat:@"Votes: %d", voteCount]];
}

- (void)createVoteLabel
{
    //Votes label creation
    self.votesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self setVoteCount:self.votes];
    self.votesLabel.size = [self.votesLabel.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
}


- (void)createVoteButton:(UIImage *)buttonImage buttonImageHighlight:(UIImage *)buttonImageHighlight
{
    //vote for this comment button creation
    self.voteBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT)];
    
    // Set the background for any states you plan to use
    [self.voteBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.voteBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.voteBtn setTitle:@"+1" forState:UIControlStateNormal];
    [self.voteBtn setTitle:@"+1" forState:UIControlStateHighlighted];
}


- (void)createDeleteButton:(UIImage *)buttonImage buttonImageHighlight:(UIImage *)buttonImageHighlight
{
    self.deleteBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT)];
    
    // Set the background for any states you plan to use
    [self.deleteBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.deleteBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.deleteBtn setTitle:@"Del" forState:UIControlStateNormal];
}


- (void)createCommentContent
{
    self.commentContent = [MGLine multilineWithText:self.commentText font:nil width:self.size.width padding:UIEdgeInsetsMake(16, 16, 16, 16)];
}


-(void)setup
{
    [super setup];

    
    //setting up standard style elements
    UIEdgeInsets standardMarginOrPadding = UIEdgeInsetsMake(0, 8, 0, 8);
    
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [self createVoteLabel];
    
    //TODO:disable vote button if user's comment
    [self createVoteButton:buttonImage buttonImageHighlight:buttonImageHighlight];
    
    self.voteBtn.margin = standardMarginOrPadding;


    //create delete button, hide by default
    [self createDeleteButton:buttonImage buttonImageHighlight:buttonImageHighlight];
    
    self.deleteBtn.margin = standardMarginOrPadding;
    [self.deleteBtn setHidden:YES];
    

    
    NSMutableArray *voteItems = [[NSMutableArray alloc] init];
    [voteItems addObject:self.votesLabel];
    [voteItems addObject:self.voteBtn];
    
    NSMutableArray *commentModItems = [[NSMutableArray alloc] init];

    [commentModItems addObject:self.deleteBtn];
    

    
    self.commentDetails = [MGLine lineWithLeft:self.username right:commentModItems size:CGSizeMake(360, 36)];
    
    self.commentDetails.middleItems = voteItems;

    [self createCommentContent];
    
    
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
