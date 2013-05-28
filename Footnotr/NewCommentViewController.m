//
//  NewCommentViewController.m
//  Footnotr
//
//  Created by Sam Homer on 5/17/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "NewCommentViewController.h"
#import "UIControl+MGEvents.h"

@interface NewCommentViewController ()

@end

@implementation NewCommentViewController

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
    
    NSLog(@"In new comm VC->view did load");
    
    self.title = @"Add A Comment";

    [self.commView.cancelBtn onControlEvent:UIControlEventTouchUpInside do:^{
        
        [self.delegate newCommentViewControllerDidCancel:self];
    
    }];
    
    [self.commView.saveBtn onControlEvent:UIControlEventTouchUpInside do:^{
    
        NSString *newCommentText = self.commView.editor.text;
        [self.delegate newCommentViewController:self didProvideComment:newCommentText];
        
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.superview.frame = CGRectMake(0, 0, 480, 360);//it's important to do this after presentModalViewController
    CGPoint windowCenter = [self presentingViewController].view.window.center;
    self.view.superview.center = windowCenter;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
