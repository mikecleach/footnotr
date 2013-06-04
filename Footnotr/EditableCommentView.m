//
//  EditableCommentView.m
//  Footnotr
//
//  Created by Sam Homer on 5/16/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "EditableCommentView.h"

@implementation EditableCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setup
{
    //Let's assume for now that super setup called the right createComment. Use this setup to do any delegate setting up type stuff?
    [super setup];
    
    

}


- (void)createCommentContent
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    
    //subtracting 16 from the self.size.width to account fo UItextview's left and right 8pt margins
    CGSize size = [self.commentText sizeWithFont:font
                                   constrainedToSize:CGSizeMake(self.size.width-8-8, 100000)];
    
    //UITextviews have 8 top and 8 bottom margins, so we account for them here.
    CGFloat multilineCommentHeight = size.height + 16;
    
    self.commentTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, multilineCommentHeight)];
    self.commentTV.font = font;
    self.commentTV.text = self.commentText;
    [self.commentTV setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1]];
    
    self.commentTV.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commentTV.keyboardType = UIKeyboardTypeDefault;
    self.commentTV.returnKeyType = UIReturnKeyNext;
    [self.commentTV setScrollEnabled:YES];
    
    
    //TODO: this may not be neccesary
    //        //Create done button for an input accessory view to the keyboard to finish editing a comment.
    //        UIView *inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    //
    //        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //        [doneButton setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
    //        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    //        [doneButton setBackgroundColor:[UIColor blueColor]];
    //
    //
    //        [doneButton onControlEvent:UIControlEventTouchUpInside do:^{
    //            [myTextView resignFirstResponder];
    //
    //        }];
    //
    //        [inputAccView addSubview:doneButton];
    //
    //        [myTextView setInputAccessoryView:inputAccView];
    //
    
    self.commentContent = [MGLine lineWithLeft:self.commentTV right:nil size:CGSizeMake(self.size.width, multilineCommentHeight)];
    
    //self.commentContent.margin = UIEdgeInsetsMake(16, 16, 16, 16);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
