//
//  CommentView.h
//  Footnotr
//
//  Created by Sam Homer on 5/1/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "MGBox.h"
#import "MGLine.h"
#import "MGButton.h"
//#import "UIButton+BlockEvents.h"
#import "CommentModel.h"


@interface CommentView : MGBox

@property (strong, nonatomic) CommentModel *comment;
@property (strong, nonatomic) NSString *username;

@property (strong, nonatomic) MGLine *commentDetails;
@property (strong, nonatomic) MGLine *commentContent;
@property (strong, nonatomic) MGButton *voteBtn;
@property (strong, nonatomic) MGButton *deleteBtn;
@property (strong, nonatomic) UILabel *votesLabel;


- (id) initWithComment:(CommentModel *)comment andFrame:(CGRect)frame;


@end
