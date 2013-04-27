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

#define ROW_SIZE (CGSize) {180, 30}

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
	// Do any additional setup after loading the view
    
//    UITextView *commentsView = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, 100, 100)];
//    [commentsView setText:@"Test comment 1"];
//    [commentsView setEditable:NO];
//    //[self.view addSubview:commentsView];
//    
    //self.scroller = [MGScrollView scrollerWithSize:CGSizeMake(200, 300)];
    
    NSLog(@"in viewDidLoad");

    [self loadCommentsIntoView];
    
//
//    [self.view addSubview:scroller];
    [self.scroller layoutWithSpeed:0.3 completion:nil];
}

- (void)loadCommentsIntoView
{
 
    MGTableBoxStyled *section = MGTableBoxStyled.box;
    [self.scroller.boxes addObject:section];
    
    MGLineStyled *head = [MGLineStyled lineWithLeft:@"Comments" right:nil
                                  size:ROW_SIZE];
    [section.topLines addObject:head];
    
    
    for (NSDictionary *commDict in self.comments) {
        MGLineStyled *infoBar = [MGLineStyled lineWithLeft:[commDict objectForKey:@"user"] right:nil size:ROW_SIZE];
        [section.topLines addObject:infoBar];
        
        MGLineStyled *comment = [MGLineStyled lineWithMultilineLeft:[commDict objectForKey:@"comment_text"] right:nil width:160 minHeight:40];
        [section.topLines addObject:comment];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
