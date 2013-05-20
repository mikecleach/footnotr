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
#import "EditableCommentView.h"

#import "UserManager.h"
#import "UIControl+MGEvents.h"

#import "APIHttpClient.h"

#import "FPPopoverController.h"

#define ROW_SIZE (CGSize) {300, 30}

@interface CommentsViewController ()

@end

@implementation CommentsViewController {

    CommentHeaderView *commentsHeader;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
    NSLog(@"in viewDidLoad");
    
    //get the current user and set bool if this comment was made by logged-in user
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    

    
    commentsHeader = [[CommentHeaderView alloc] initWithFrame:CGRectMake(0, 0, 360, 96)];//CGRectMake(0, 0, 280, 380)];//[CommentHeaderView commentHeaderViewForSize:ROW_SIZE];
    
    
    //TODO:use uicontrol+mgevents here instead, 
    [commentsHeader.addCommentButton addTarget:self action:@selector(addCommentTapped:) forControlEvents:UIControlEventTouchDown];
    
    
    self.commentsScroller.contentLayoutMode = MGLayoutTableStyle;

    self.commentsScroller.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
    
    [self.commentsScroller setContentSize:CGSizeMake(360, 480)];
    
    [self.commentsScroller.boxes addObject:commentsHeader];
    
    
    for (CommentModel *commentModel in self.annot.comments) {
        //CommentView *newCommentView = [[CommentView alloc] initWithComment:commentModel andFrame:CGRectMake(0, 0, 360, 100)];
        
        CommentView *newCommentView;
        
        //If user created comment, create an editable view, disable voting and show delete button
        if ([commentModel.username isEqualToString:loggedInUser.username]) {
            
            newCommentView = [[EditableCommentView alloc] initWithComment:commentModel.comment andUsername:commentModel.username andVoteCount:commentModel.votes.count andFrame:CGRectMake(0, 0, 360, 100)];
            
            [newCommentView.voteBtn setEnabled:NO];
            [newCommentView.deleteBtn setHidden:NO];
            
            //TODO:presumably we add the delegate here to deal with edited comments.
        }
        //create standard comment view, set highlighted state
        else {
            newCommentView = [[CommentView alloc] initWithComment:commentModel.comment andUsername:commentModel.username andVoteCount:commentModel.votes.count andFrame:CGRectMake(0, 0, 360, 100)];
            
            //if user already voted, highlight the vote button
            if ([commentModel userDidVote:loggedInUser]) {
                [newCommentView.voteBtn setHighlighted:YES];
            }
        }
        
        
        [newCommentView.voteBtn onControlEvent:UIControlEventTouchUpInside do:^{
            
            void (^addingVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                VoteModel *createdVote = [[VoteModel alloc] init];
                createdVote.user = loggedInUser;
                createdVote.pk = [[JSON objectForKey:@"pk"] intValue];
                createdVote.username = [JSON objectForKey:@"username"];
                
                //TODO:What if vote failed? This assumes it doesnt
                //vote was successful, so we add to model, which should notify VC, which should update view button
                [commentModel addVote:createdVote];
                
                [newCommentView.voteBtn setHighlighted:YES];
                //self.voteBtn.highlighted = [self.comment userDidVote:loggedInUser];
                
                //this should update the votes label
                [newCommentView setVoteCount:commentModel.votes.count];
                
                
            };
            
            void (^deleteVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                //TODO:what if delete fails? need to handle it
                
                
                VoteModel *deletedVote = [commentModel getVoteForUser:loggedInUser];
                
                [commentModel removeVote:deletedVote];
                
                    

                [newCommentView.voteBtn setHighlighted:NO];

                [newCommentView setVoteCount:commentModel.votes.count];
            };
            
            
            APIHttpClient *sharedClient = [APIHttpClient sharedClient];
            //TODO:hardcoding all up in here
            //if already voted, delete that vote. Otherwise add vote
            if([commentModel userDidVote:loggedInUser]) {
                
                
                
                NSString *path = [NSString stringWithFormat:@"votes/%d/", [commentModel getVoteForUser:loggedInUser].pk];
                
                [sharedClient deletePath:path parameters:nil success:deleteVoteBlock failure:nil];
            }
            else {
                
                NSMutableDictionary *newVote = [[NSMutableDictionary alloc] init];
                [newVote setObject:[NSString stringWithFormat:@"%d", commentModel.pk] forKey:@"comment"];
                [newVote setObject:[NSString stringWithFormat:@"%d", loggedInUser.pk] forKey:@"user"];
                
                
                NSString *path = @"votes/new";
                [sharedClient postPath:path parameters:newVote success:addingVoteBlock failure:nil];
            }
            
            NSLog(@"tapped");
        }];
        
        
        [newCommentView.deleteBtn onControlEvent:UIControlEventTouchUpInside do:^{
            
            void (^deleteVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                //FIXME:remove comment from view if delete succeeded
                
                
                
            };
            
            
            APIHttpClient *sharedClient = [APIHttpClient sharedClient];
            
            NSString *path = [NSString stringWithFormat:@"comments/%d/", commentModel.pk];
            
            [sharedClient deletePath:path parameters:nil success:deleteVoteBlock failure:nil];
            
        }];
        
        
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

- (void) addCommentTapped: (id)sender
{
    NSLog(@"add button tapped");
    
    UserManager *um = [UserManager sharedManager];
    [self setModalPresentationStyle:UIModalPresentationFormSheet];
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    NewCommentViewController *newCommVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newCommentViewController"];
    [newCommVC setDelegate:self];
    [newCommVC setTitle:@"Add A Comment"];
    
    [self presentViewController:newCommVC animated:YES completion:nil];

    
}

- (void) newCommentViewControllerDidCancel:(NewCommentViewController *)newCommVC
{
    NSLog(@"canceled new comment");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) newCommentViewController:(NewCommentViewController *)newCommVC didProvideComment:(NSString *)comment
{

    //TODO:veto dismissing the view controller if save to server fails
    void (^createCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"create comment on server call succeeded");
        
        NSError *error;
        CommentModel *newlyCreatedComment = [[CommentModel alloc] initWithDictionary:JSON error:&error];
        
        //TODO:Update model with newly created comment
        [self.annot addComment:newlyCreatedComment];
        
        
        //TODO:Add new view to comments scroller and scroll it into view
        
        
    };
    
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    
    NSMutableDictionary *newCommentDict = [[NSMutableDictionary alloc] init];
    [newCommentDict setObject:[NSString stringWithFormat:@"%d",self.annot.pk] forKey:@"annotation"];
    [newCommentDict setObject:[NSString stringWithFormat:@"%d",loggedInUser.pk] forKey:@"user"];
    [newCommentDict setObject:comment forKey:@"comment"];
    
    APIHttpClient *sharedClient = [APIHttpClient sharedClient];
    
    NSString *path = @"comments/new";
    
    [sharedClient postPath:path parameters:newCommentDict success:createCommentBlock failure:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
