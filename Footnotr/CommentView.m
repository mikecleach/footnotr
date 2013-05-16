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


- (void)createVoteLabel
{
    //Votes label creation
    self.votesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.votesLabel.text = [NSString stringWithFormat:@"Votes: %d", self.comment.votes.count];
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


-(void)setup
{
    [super setup];
    
    //get the current user and set bool if this comment was made by logged-in user
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    
    
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
 
    
    [self createDeleteButton:buttonImage buttonImageHighlight:buttonImageHighlight];
    
    self.deleteBtn.margin = standardMarginOrPadding;
    
    [self.deleteBtn onControlEvent:UIControlEventTouchUpInside do:^{
        
        void (^deleteVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
            
            //FIXME:remove comment from view if delete succeeded
            
            

        };
        
        
        APIHttpClient *sharedClient = [APIHttpClient sharedClient];

        NSString *path = [NSString stringWithFormat:@"comments/%d/", self.comment.pk];
        
        [sharedClient deletePath:path parameters:nil success:deleteVoteBlock failure:nil];

    }];
    
    
    NSMutableArray *voteItems = [[NSMutableArray alloc] init];
    [voteItems addObject:self.votesLabel];
    [voteItems addObject:self.voteBtn];
    
    NSMutableArray *commentModItems = [[NSMutableArray alloc] init];
    
    BOOL commentMadeByCurrentUser = [loggedInUser.username isEqualToString:self.comment.username];
    if(commentMadeByCurrentUser) {
        [commentModItems addObject:self.deleteBtn];
    }
    
    self.commentDetails = [MGLine lineWithLeft:self.comment.username right:commentModItems size:CGSizeMake(360, 36)];
    
    self.commentDetails.middleItems = voteItems;
    
    
    //if current user made comment, use editable textview instead
    if (commentMadeByCurrentUser) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        
        CGSize size = [self.comment.comment sizeWithFont:font
                                       constrainedToSize:CGSizeMake(self.size.width, 100000)];
        
        CGFloat multilineCommentHeight = size.height;
        
        UITextView *myTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, multilineCommentHeight)];
        myTextView.font = font;
        myTextView.text = self.comment.comment;
        myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        myTextView.keyboardType = UIKeyboardTypeDefault;
        myTextView.returnKeyType = UIReturnKeyNext;
        
        
//TODO: this may not be neccesary
//        //Create done button for an input accessory view to the keyboard to finish editing a comment.
//        UIView *inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
//        
//        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [doneButton setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
//        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
//        [doneButton setBackgroundColor:[UIColor blueColor]];
//        
//        
//        [doneButton onControlEvent:UIControlEventTouchUpInside do:^{
//            [myTextView resignFirstResponder];
//            
//        }];
//        
//        [inputAccView addSubview:doneButton];
//        
//        [myTextView setInputAccessoryView:inputAccView];
//        
        
        self.commentContent = [MGLine lineWithLeft:myTextView right:nil size:CGSizeMake(self.size.width, multilineCommentHeight)];
        
        
    }
    else {
        self.commentContent = [MGLine multilineWithText:self.comment.comment font:nil width:self.size.width padding:UIEdgeInsetsMake(16, 16, 16, 16)];
        
    }
    
    
    
    
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
