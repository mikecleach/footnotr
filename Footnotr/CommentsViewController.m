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
#import "UIAlertView+Blocks.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"

#import "APIHttpClient.h"

#import "FPPopoverController.h"
#import "APPDFInformation.h"


#define ROW_SIZE (CGSize) {300, 30}

@interface CommentsViewController ()

@end

@implementation CommentsViewController {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    
    NSLog(@"in viewDidLoad");
    
    //get the current user and set bool if this comment was made by logged-in user
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    
    
    [self.commentsHeader setFrame:CGRectMake(0, 0, 360, 100)];
    
    if ([loggedInUser.username isEqualToString:self.annot.username]) {
        [self.commentsHeader.deleteAnnotButton setHidden:NO];
        
        [self.commentsHeader.deleteAnnotButton onControlEvent:UIControlEventTouchUpInside do:^{
            
            //Using a block based UIAlertView category, avoids that messy delegate stuff
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Annotation" message:@"Are you sure you want to delete this annotation?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            
            [alert showWithBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    
                    void (^deleteAnnotationBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                        
                        NSLog(@"After delete annotation web request");
                        
                        [self.parentArticle removeAnnotation:self.annot];
                        
                        [self.parentPdfInfo removeAnnotation:self.annot.annot];
                        
                        
                        [self.parentPdfView reloadAnnotationViews];
                        
                        [self.parentPopoverController dismissPopoverAnimated:NO];
                        
                        
                    };
                    
                    void (^failedDeleteAnnotationBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                        
                        NSLog(@"***FAILED*** to delete annotation");
                        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Annotation Request Failed" message:@"Annotation was not deleted. Please try again."];
                        notice.delay = 4.0;
                        [notice show];
                    };
                    
                    
                    APIHttpClient *sharedClient = [APIHttpClient sharedClient];
                    
                    NSString *path = [NSString stringWithFormat:@"annotations/%d/", self.annot.pk];
                    
                    [sharedClient deletePath:path parameters:nil success:deleteAnnotationBlock failure:failedDeleteAnnotationBlock];
                    
                }
            } cancelBlock:^{
                
            }];
            

            
        }];
        
    }
    
    
    [self.commentsHeader.sortVotesButton onControlEvent:UIControlEventTouchUpInside do:^{
        
        
        [self.commentsScroller.boxes sortUsingComparator:^NSComparisonResult(id a, id b){
            
            int first = ((CommentView *)a).votes;
            int second = ((CommentView *)b).votes;
            
            if (first < second) {
                return NSOrderedDescending;
            }
            else if (first > second) {
                return NSOrderedAscending;
            }
            else
                return NSOrderedSame;
            

        }];
        
        
        
        [self.commentsScroller layout];
    }];
    
    
    [self.commentsHeader.sortDateButton onControlEvent:UIControlEventTouchUpInside do:^{
    
    
        [self.commentsScroller.boxes sortUsingComparator:^NSComparisonResult(id a, id b){
            
            NSDate *first = ((CommentView *)a).created;
            NSDate *second = ((CommentView *)b).created;
            
            
            return [first compare:second];
        }];
        
        [self.commentsScroller layout];
    }];
    
    
    
    //TODO:use uicontrol+mgevents here instead, 
    [self.commentsHeader.addCommentButton addTarget:self action:@selector(addCommentTapped:) forControlEvents:UIControlEventTouchDown];
    
    self.commentsHeader.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
        
    
    
    self.commentsScroller.contentLayoutMode = MGLayoutTableStyle;

    self.commentsScroller.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
    
    [self.commentsScroller setContentSize:CGSizeMake(360, 480)];
      
    
    for (CommentModel *commentModel in self.annot.comments) {
        
        CommentView *newCommentView;
        
        //If user created comment, create an editable view, disable voting and show delete button
        if ([commentModel.username isEqualToString:loggedInUser.username]) {
            
            newCommentView = [[EditableCommentView alloc] initWithComment:commentModel.comment andUsername:commentModel.username andVoteCount:commentModel.votes.count andFrame:CGRectMake(0, 0, 348, 100)];
            
            [newCommentView.voteBtn setEnabled:NO];
            [newCommentView.deleteBtn setHidden:NO];
            
            //Act as each textview's delegate so we can, on end editing, trigger the self-assignment workaround that invokes the change KVO below.
            ((EditableCommentView *)newCommentView).commentTV.delegate = self;
            
            [((EditableCommentView *)newCommentView).commentTV onChangeOf:@"text" do:^{
            
                void (^updateCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                    
                    //Update the model with the updated text
                    commentModel.comment = ((EditableCommentView *)newCommentView).commentTV.text;
                };
                
                
                void (^failedUpdateCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                    
                    NSLog(@"***FAILED*** to update comment");
                    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Comment Request Failed" message:@"Comment was not updated. Please try again."];
                    notice.delay = 4.0;
                    [notice show];
                    
                };
                
                NSMutableDictionary *updateCommentDict = [[NSMutableDictionary alloc] init];
                [updateCommentDict setObject:((EditableCommentView *)newCommentView).commentTV.text forKey:@"comment"];
                
                
                APIHttpClient *sharedClient = [APIHttpClient sharedClient];
                
                NSString *path = [NSString stringWithFormat:@"comments/%d/", commentModel.pk];
                
                [sharedClient patchPath:path parameters:updateCommentDict success:updateCommentBlock failure:failedUpdateCommentBlock];
                
            }];
            
            
        }
        //create standard comment view, set highlighted state
        else {
            newCommentView = [[CommentView alloc] initWithComment:commentModel.comment andUsername:commentModel.username andVoteCount:commentModel.votes.count andFrame:CGRectMake(0, 0, 348, 100)];
            
            //if user already voted, highlight the vote button
            if ([commentModel userDidVote:loggedInUser]) {
                [newCommentView.voteBtn setHighlighted:YES];
            }
        }
        
        //Associate created date so we can sort easily. May be a hack.
        newCommentView.created = commentModel.created;
        
        
        [newCommentView.voteBtn onControlEvent:UIControlEventTouchUpInside do:^{
            
            void (^addingVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                VoteModel *createdVote = [[VoteModel alloc] init];
                createdVote.user = loggedInUser;
                createdVote.pk = [[JSON objectForKey:@"pk"] intValue];
                createdVote.username = [JSON objectForKey:@"username"];
                

                [commentModel addVote:createdVote];
                
                [newCommentView.voteBtn setHighlighted:YES];
                //self.voteBtn.highlighted = [self.comment userDidVote:loggedInUser];
                
                //this should update the votes label
                [newCommentView setVoteCount:commentModel.votes.count];
                
            };
            
            void (^failedAddVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSLog(@"***FAILED*** to add vote");
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Vote Request Failed" message:@"Vote was not saved. Please try again."];
                notice.delay = 4.0;
                [notice show];
                
            };
            
            
            void (^deleteVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                VoteModel *deletedVote = [commentModel getVoteForUser:loggedInUser];
                
                [commentModel removeVote:deletedVote];
                
                
                [newCommentView.voteBtn setHighlighted:NO];

                [newCommentView setVoteCount:commentModel.votes.count];
            };
            
            void (^failedDeleteVoteBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSLog(@"***FAILED*** to delete vote");
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Vote Request Failed" message:@"Vote was not deleted. Please try again."];
                notice.delay = 4.0;
                [notice show];
                
            };
            
            
            APIHttpClient *sharedClient = [APIHttpClient sharedClient];

            //if already voted, delete that vote. Otherwise add vote
            if([commentModel userDidVote:loggedInUser]) {
                
                
                
                NSString *path = [NSString stringWithFormat:@"votes/%d/", [commentModel getVoteForUser:loggedInUser].pk];
                
                [sharedClient deletePath:path parameters:nil success:deleteVoteBlock failure:failedDeleteVoteBlock];
            }
            else {
                
                NSMutableDictionary *newVote = [[NSMutableDictionary alloc] init];
                [newVote setObject:[NSString stringWithFormat:@"%d", commentModel.pk] forKey:@"comment"];
                [newVote setObject:[NSString stringWithFormat:@"%d", loggedInUser.pk] forKey:@"user"];
                
                
                NSString *path = @"votes/new";
                [sharedClient postPath:path parameters:newVote success:addingVoteBlock failure:failedAddVoteBlock];
            }
            
            NSLog(@"tapped");
        }];
        

        [newCommentView.deleteBtn onControlEvent:UIControlEventTouchUpInside do:^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Comment" message:@"Are you sure you want to delete this comment?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            
            [alert showWithBlock:^(NSInteger buttonIndex) {
                //If Yes was answered to "Delete this comment?"
                if (buttonIndex == 1) {
                    void (^deleteCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                        
                        
                        [self.annot removeComment:commentModel];
                        
                        
                        [self.commentsScroller.boxes removeObject:newCommentView];
                        
                        [self.commentsScroller layoutWithSpeed:0.5 completion:nil];
                        
                        
                    };
                    
                    void (^failedDeleteCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                        
                        NSLog(@"***FAILED*** to delete comment");
                        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Comment Request Failed" message:@"Comment was not deleted. Please try again."];
                        notice.delay = 4.0;
                        [notice show];
                        
                    };
                    
                    
                    APIHttpClient *sharedClient = [APIHttpClient sharedClient];
                    
                    NSString *path = [NSString stringWithFormat:@"comments/%d/", commentModel.pk];
                    
                    [sharedClient deletePath:path parameters:nil success:deleteCommentBlock failure:failedDeleteCommentBlock];
                    
                }
            } cancelBlock:^{
                
            }];

            
        }];
        
        
        [self.commentsScroller.boxes addObject:newCommentView];
    }
    
    [self.commentsHeader layout];//WithSpeed:0.5 completion:nil];
    [self.commentsScroller layoutWithSpeed:0.5 completion:nil];

}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    //FIXME:This is a workaround to trigger our KVO notification
    //May not be reliable since UIKit stuff typically isnt KVO compliant
    textView.text = textView.text;
}


- (void) addCommentTapped: (id)sender
{
    NSLog(@"add button tapped");
    
    [self setModalPresentationStyle:UIModalPresentationFormSheet];
    [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    NewCommentViewController *newCommVC = [self.storyboard instantiateViewControllerWithIdentifier:@"newCommentViewController"];
    
    //Fixing the form sheet size nonsense
    ((NewCommentView *)newCommVC.view).editor.size = CGSizeMake(380, newCommVC.view.size.height);
    [newCommVC setDelegate:self];
    [newCommVC setTitle:@"Add A Comment"];
    
    [self presentViewController:newCommVC animated:YES completion:nil];
    newCommVC.view.superview.frame = CGRectMake(0, 0, 380, 200);//it's important to do this after presentModalViewController
    newCommVC.view.superview.center = CGPointMake(roundf(self.view.superview.center.x), roundf(self.view.superview.center.y));

    
}




- (void) newCommentViewControllerDidCancel:(NewCommentViewController *)newCommVC
{
    NSLog(@"canceled new comment");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void) newCommentViewController:(NewCommentViewController *)newCommVC didProvideComment:(NSString *)comment
{


    void (^createCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"create comment on server call succeeded");
        
        UserManager *uManager = [UserManager sharedManager];
        UserModel *loggedInUser = uManager.loggedInUser;
        
        
        NSError *error;
        //Create and update model with new comment
        CommentModel *newlyCreatedComment = [[CommentModel alloc] initWithDictionary:JSON error:&error];
        
        [self.annot addComment:newlyCreatedComment];
        
        NSMutableDictionary *newVote = [[NSMutableDictionary alloc] init];
        [newVote setObject:[NSString stringWithFormat:@"%d", newlyCreatedComment.pk] forKey:@"comment"];
        [newVote setObject:[NSString stringWithFormat:@"%d", loggedInUser.pk] forKey:@"user"];
        
        
        void (^failedVoteForNewCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
            
            NSLog(@"***FAILED*** to add user vote for new comment");
            WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Vote Request Failed" message:@"Vote was not added. Please try again."];
            notice.delay = 4.0;
            [notice show];
            
        };
        
        NSString *path = @"votes/new";
        //TODO:Should have a proper success function here instead of assuming success
        [[APIHttpClient sharedClient] postPath:path parameters:newVote success:nil failure:failedVoteForNewCommentBlock];
        
        
        //Set the vote count to 1 to match the vote we just sent to server
        EditableCommentView *newCommentView = [[EditableCommentView alloc] initWithComment:newlyCreatedComment.comment andUsername:loggedInUser.username andVoteCount:1 andFrame:CGRectMake(0, 0, 360, 100)];
        
        [newCommentView.deleteBtn setHidden:NO];
        [newCommentView.voteBtn setEnabled:NO];
        
        
        //TODO:This is duplicate code. Refactor associating blocks with buttons.
        [newCommentView.deleteBtn onControlEvent:UIControlEventTouchUpInside do:^{
            
            void (^deleteCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                
                [self.annot removeComment:newlyCreatedComment];
                
                
                [self.commentsScroller.boxes removeObject:newCommentView];
                
                [self.commentsScroller layoutWithSpeed:0.5 completion:nil];
                
                
            };
            
            void (^failedDeleteCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
                
                NSLog(@"***FAILED*** to delete comment");
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Comment Request Failed" message:@"Comment was not deleted. Please try again."];
                notice.delay = 4.0;
                [notice show];
                
            };
            
            
            APIHttpClient *sharedClient = [APIHttpClient sharedClient];
            
            NSString *path = [NSString stringWithFormat:@"comments/%d/", newlyCreatedComment.pk];
            
            [sharedClient deletePath:path parameters:nil success:deleteCommentBlock failure:failedDeleteCommentBlock];
            
        }];
        
        
        [self.commentsScroller.boxes addObject:newCommentView];
        [self.commentsScroller layoutWithSpeed:0.4 completion:nil];
        [self.commentsScroller scrollToView:newCommentView withMargin:10];
        
    };
    
    
    void (^failedCreateCommentBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSLog(@"***FAILED*** to create comment");
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Comment Request Failed" message:@"Comment was not saved. Please try again."];
        notice.delay = 4.0;
        [notice show];
        
    };
    
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    
    //Build the comment data dictionary
    NSMutableDictionary *newCommentDict = [[NSMutableDictionary alloc] init];
    [newCommentDict setObject:[NSString stringWithFormat:@"%d",self.annot.pk] forKey:@"annotation"];
    [newCommentDict setObject:[NSString stringWithFormat:@"%d",loggedInUser.pk] forKey:@"user"];
    [newCommentDict setObject:comment forKey:@"comment"];
    
    
    NSString *path = @"comments/new";
    
    [[APIHttpClient sharedClient] postPath:path parameters:newCommentDict success:createCommentBlock failure:failedCreateCommentBlock];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
