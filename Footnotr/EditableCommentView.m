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
    
    CGSize size = [self.commentText sizeWithFont:font
                                   constrainedToSize:CGSizeMake(self.size.width, 100000)];
    
    CGFloat multilineCommentHeight = size.height;
    
    self.commentTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, multilineCommentHeight)];
    self.commentTV.font = font;
    self.commentTV.text = self.commentText;
    self.commentTV.autocorrectionType = UITextAutocorrectionTypeNo;
    self.commentTV.keyboardType = UIKeyboardTypeDefault;
    self.commentTV.returnKeyType = UIReturnKeyNext;
    
    
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
    
    self.commentContent.margin = UIEdgeInsetsMake(16, 16, 16, 16);
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
