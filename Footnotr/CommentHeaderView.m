//
//  CommentHeaderView.m
//  Footnotr
//
//  Created by Sam Homer on 5/1/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "CommentHeaderView.h"

#define HEADER_FONT [UIFont fontWithName:@"HelveticaNeue" size:24]
#define ROW_HEIGHT_STD 30

@implementation CommentHeaderView

- (void)setup
{
    NSLog(@"called comment header view setup");
    
    [super setup];
    
    self.deleteAnnotButton = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];

    UIImage *redButtonImage = [[UIImage imageNamed:@"orangeButton.png"]
                               resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    [self.deleteAnnotButton setBackgroundImage:redButtonImage forState:UIControlStateNormal];
    [self.deleteAnnotButton setTitle:@"X" forState:UIControlStateNormal];
    
    [self.deleteAnnotButton setHidden:YES];

    
    self.commentHeaderBar = [MGLineStyled lineWithLeft:@"Comments" right:self.deleteAnnotButton size:CGSizeMake(320,48)];
    
    [self.commentHeaderBar setFont:HEADER_FONT];
    
    
    
    [self.boxes addObject:self.commentHeaderBar];
    
    
    //setting up standard style elements
    UIEdgeInsets standardMarginOrPadding = UIEdgeInsetsMake(0, 8, 0, 8);
    
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    
    //sort comments by vote button creation
    self.sortVotesButton = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT_STD)];
    

    // Set the background for any states you plan to use
    [self.sortVotesButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.sortVotesButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.sortVotesButton setTitle:@"Votes" forState:UIControlStateNormal];
    self.sortVotesButton.margin = standardMarginOrPadding;
    
    
    
    //sort by date button creation
    self.sortDateButton = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, ROW_HEIGHT_STD)];

    // Set the background for any states you plan to use
    [self.sortDateButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.sortDateButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.sortDateButton setTitle:@"Date" forState:UIControlStateNormal];
    
    //array of sort buttona
    NSMutableArray *sortItems = [[NSMutableArray alloc] init];
    
    [sortItems addObject:self.sortVotesButton];
    [sortItems addObject:self.sortDateButton];
    self.sortDateButton.margin = standardMarginOrPadding;
    
    
    
    //add new comment button creation
    self.addCommentButton = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 100, ROW_HEIGHT_STD)];
    

    // Set the background for any states you plan to use
    [self.addCommentButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.addCommentButton setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    [self.addCommentButton setTitle:@"Add Comment" forState:UIControlStateNormal];
    self.addCommentButton.padding = standardMarginOrPadding;

    
    
    //create and setup subheader options line
    self.commentSubheaderBar = [MGLine lineWithLeft:@"Sort By:"right:self.addCommentButton size:CGSizeMake(320, 48)];
    
    
    [self.commentSubheaderBar setMiddleItems:sortItems];
    
    
    self.commentSubheaderBar.borderStyle = MGBorderEtchedBottom;
    
    self.commentSubheaderBar.margin = UIEdgeInsetsMake(6, 6, 6, 6);
    
    
    
    [self.boxes addObject:self.commentSubheaderBar];
    
}

- (void)layout
{
    [super layout];
    
    UILabel *commentLbl = [self.commentHeaderBar.leftItems objectAtIndex:0];
    [commentLbl setCenter:self.commentHeaderBar.center];
    
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
