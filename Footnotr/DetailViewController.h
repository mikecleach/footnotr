//
//  DetailViewController.h
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"
#import "CommentsViewController.h"
#import "ArticleModel.h"
#import "AnnotationModel.h"


@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, APAnnotatingPDFViewDelegate, APPDFProcessorDelegate>


@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSString *documentDir;

@property (weak, nonatomic) IBOutlet CommentsViewController *commentsVC;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (strong, nonatomic) MGTableBox *annotCreationMenu;

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableData *serverResponse;
@property (strong, nonatomic) APPDFInformation *info;
@property (strong, nonatomic) ArticleModel *article;


@end
