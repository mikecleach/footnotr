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

@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *username;
@property int votes;

@property(strong, nonatomic) NSDate *created;

@property (strong, nonatomic) MGLine *commentDetails;
@property (strong, nonatomic) MGLine *commentContent;
@property (strong, nonatomic) MGButton *voteBtn;
@property (strong, nonatomic) MGButton *deleteBtn;
@property (strong, nonatomic) UILabel *votesLabel;

- (id)initWithComment:(NSString *)commentText andUsername:(NSString *)username andVoteCount:(int)voteCount andFrame:(CGRect)frame;

- (id) initWithFrame:(CGRect)frame;

- (void)setVoteCount:(int)voteCount;

@end
