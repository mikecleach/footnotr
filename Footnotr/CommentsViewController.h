//
//  CommentsViewController.h
//  Footnotr
//
//  Created by Sam Homer on 4/24/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGScrollView.h"


@interface CommentsViewController : UIViewController

@property (strong, nonatomic) IBOutlet MGScrollView *scroller;
@property (nonatomic, strong) NSArray *comments;

@end
