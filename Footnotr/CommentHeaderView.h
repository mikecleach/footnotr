//
//  CommentHeaderView.h
//  Footnotr
//
//  Created by Sam Homer on 5/1/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "MGTableBox.h"
#import "MGTableBoxStyled.h"
#import "MGButton.h"
#import "MGLine.h"
#import "MGLineStyled.h"

@interface CommentHeaderView : MGBox

@property (strong, nonatomic) MGButton *sortVotesButton;
@property (strong, nonatomic) MGButton *sortDateButton;
@property (strong, nonatomic) MGButton *addCommentButton;
@property (strong, nonatomic) MGButton *deleteAnnotButton;

@property (strong, nonatomic) MGLine *sortLine;

@property (strong, nonatomic) MGLine *commentHeaderBar;
@property (strong, nonatomic) MGLine *commentSubheaderBar;

@end
