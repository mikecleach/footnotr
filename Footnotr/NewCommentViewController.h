//
//  NewCommentViewController.h
//  Footnotr
//
//  Created by Sam Homer on 5/17/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewCommentView.h"

@protocol NewCommentViewDelegate;

@interface NewCommentViewController : UIViewController

@property (weak, nonatomic) id<NewCommentViewDelegate>delegate;

@property (strong, nonatomic) IBOutlet NewCommentView *commView;

@end

@protocol NewCommentViewDelegate <NSObject>

- (void) newCommentViewControllerDidCancel:(NewCommentViewController *)newCommVC;

- (void) newCommentViewController:(NewCommentViewController *)newCommVC didProvideComment:(NSString *)comment;

@end
