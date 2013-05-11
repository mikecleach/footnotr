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

@interface CommentsViewController : UIViewController

@property (strong, nonatomic) IBOutlet MGScrollView *commentsScroller;
@property (nonatomic, strong) NSArray *comments;



@end
