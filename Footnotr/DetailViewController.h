//
//  DetailViewController.h
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, APAnnotatingPDFViewDelegate, APPDFProcessorDelegate>
{
    IBOutlet UIView *hostView;

    APPDFDocument *pdfDocument;
    APAnnotatingPDFViewController *pdfView;
}
@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
