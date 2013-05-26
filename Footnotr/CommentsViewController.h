//
//  CommentsViewController.h
//  Footnotr
//
//  Created by Sam Homer on 4/24/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"
#import "MGBox.h"
#import "MGTableBox.h"

#import "ArticleModel.h"
#import "AnnotationModel.h"

#import "FPPopoverController.h"
#import "APAnnotatingPDFViewController.h"
#import "NewCommentViewController.h"

@class APPDFInformation;

@interface CommentsViewController : UIViewController<NewCommentViewDelegate>

@property (strong, nonatomic) IBOutlet MGScrollView *commentsScroller;
@property (strong, nonatomic) AnnotationModel *annot;
@property (strong, nonatomic) FPPopoverController *parentPopoverController;
@property (strong, nonatomic) ArticleModel *parentArticle;
@property (strong, nonatomic) APPDFInformation *parentPdfInfo;
@property (strong, nonatomic) APAnnotatingPDFViewController *parentPdfView;

- (void) addCommentTapped: (id) sender;

@end
