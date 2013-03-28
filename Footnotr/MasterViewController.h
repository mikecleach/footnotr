//
//  MasterViewController.h
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
