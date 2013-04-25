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

@interface CommentsViewController ()

@end

@implementation CommentsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    UITextView *commentsView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, 100, 100)];
//    [commentsView setText:@"Test comment 1"];
//    [commentsView setEditable:NO];
//    //[self.view addSubview:commentsView];
//    
//    MGScrollView *scroller = [MGScrollView scrollerWithSize:CGSizeMake(200, 300)];
//    
//    MGTableBoxStyled *section = MGTableBoxStyled.box;
//    [scroller.boxes addObject:section];
//    
//    // a default row size
//    CGSize rowSize = (CGSize){180, 80};
//    NSLog(@"in viewDidLoad");
//    // a header row
//    MGLineStyled *header = [MGLineStyled lineWithLeft:@"My First Table" right:nil size:rowSize];
//    header.leftPadding = header.rightPadding = 16;
//    [section.topLines addObject:header];
//    
//    [self.view addSubview:scroller];
//    [scroller layoutWithSpeed:0.3 completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
