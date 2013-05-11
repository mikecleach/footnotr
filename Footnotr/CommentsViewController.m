//
//  CommentsViewController.m
//  Footnotr
//
//  Created by Sam Homer on 4/24/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "CommentsViewController.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "CommentModel.h"
#import "CommentHeaderView.h"
#import "CommentView.h"

#define ROW_SIZE (CGSize) {300, 30}

@interface CommentsViewController ()

@end

@implementation CommentsViewController {

    MGBox *commentsHeader;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
//    UITextView *commentsView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, 100, 100)];
//    [commentsView setText:@"Test comment 1"];
//    [commentsView setEditable:NO];
//    //[self.view addSubview:commentsView];
//    
    //self.commentsScroller = [MGScrollView scrollerWithSize:CGSizeMake(300, 400)];
    
    NSLog(@"in viewDidLoad");

    
    commentsHeader = [[CommentHeaderView alloc] initWithFrame:CGRectMake(0, 0, 360, 96)];//CGRectMake(0, 0, 280, 380)];//[CommentHeaderView commentHeaderViewForSize:ROW_SIZE];
    
    self.commentsScroller.contentLayoutMode = MGLayoutTableStyle;

    self.commentsScroller.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
    
    [self.commentsScroller setContentSize:CGSizeMake(360, 480)];
    
    [self.commentsScroller.boxes addObject:commentsHeader];
    
    
    for (CommentModel *commentModel in self.comments) {
        CommentView *newCommentView = [[CommentView alloc] initWithComment:commentModel andFrame:CGRectMake(0, 0, 360, 100)];
        
        newCommentView.comment = commentModel;
        
        
        [self.commentsScroller.boxes addObject:newCommentView];
        
        //[self.commentsScroller.boxes addObject:[MGLineStyled lineWithLeft:@"HI" right:nil size:CGSizeMake(360, 36)]];
    }
    

    [self.commentsScroller layoutWithSpeed:0.5 completion:nil];
    
    //[self loadCommentsIntoView];
    
//
//    [self.view addSubview:scroller];
//    [self.scroller layoutWithSpeed:0.3 completion:nil];
}

//- (void)loadCommentsIntoView
//{
// 
//    MGTableBoxStyled *section = MGTableBoxStyled.box;
//    [self.scroller.boxes addObject:section];
//    
//    MGLineStyled *head = [MGLineStyled lineWithLeft:@"Comments" right:nil
//                                  size:ROW_SIZE];
//    [section.topLines addObject:head];
//
//    
//    for (CommentModel *comment in self.comments) {
//        MGLineStyled *infoBar = [MGLineStyled lineWithLeft:comment.user right:nil size:ROW_SIZE];
//        [section.topLines addObject:infoBar];
//        
//        MGLineStyled *commentLine = [MGLineStyled lineWithMultilineLeft:comment.comment right:nil width:160 minHeight:40];
//        [section.topLines addObject:commentLine];
//    }
//    
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
