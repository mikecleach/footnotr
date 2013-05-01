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
#import "AnnotationModel.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, APAnnotatingPDFViewDelegate, APPDFProcessorDelegate>


@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSString *documentDir;

@property (weak, nonatomic) IBOutlet CommentsViewController *commentsVC;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
