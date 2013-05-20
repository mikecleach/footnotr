//
//  NewCommentView.h
//  Footnotr
//
//  Created by Sam Homer on 5/17/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentView.h"
#import "MGButton.h"



@interface NewCommentView : MGBox



@property (strong, nonatomic) UITextView *editor;
@property (strong, nonatomic) MGButton *saveBtn;
@property (strong, nonatomic) MGButton *cancelBtn;
@property (strong, nonatomic) MGLine *toolbarLine;


@end
