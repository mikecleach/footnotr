//
//  DetailViewController.h
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
