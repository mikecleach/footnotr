//
//  NewCommentView.m
//  Footnotr
//
//  Created by Sam Homer on 5/17/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "NewCommentView.h"
#import "UIControl+MGEvents.h"

@implementation NewCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setup
{
    
    NSLog(@"new comment view->setup");
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    
    
    NSString *initialEditorText = @"\n\n\n\n";
    
    CGSize size = [initialEditorText sizeWithFont:font
                               constrainedToSize:CGSizeMake(self.size.width, 100000)];
    
    CGFloat multilineCommentHeight = size.height;
    
    self.editor = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, multilineCommentHeight)];
    self.editor.font = font;
    //self.editor.text = ;
    self.editor.autocorrectionType = UITextAutocorrectionTypeNo;
    self.editor.keyboardType = UIKeyboardTypeDefault;
    self.editor.returnKeyType = UIReturnKeyNext;
    
    MGLine *commentLine = [MGLine lineWithLeft:self.editor right:nil size:CGSizeMake(self.size.width, size.height)];
    
    
    [self.boxes addObject:commentLine];
    
    
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    
    self.cancelBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    
    // Set the background for any states you plan to use
    [self.cancelBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];

    [self.cancelBtn onControlEvent:UIControlEventAllTouchEvents do:^{
        NSLog(@"cancel button tapped");
    }];
    
    self.saveBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    
    // Set the background for any states you plan to use
    [self.saveBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.saveBtn setTitle:@"Save" forState:UIControlStateNormal];
    
    self.toolbarLine = [MGLine lineWithLeft:self.cancelBtn right:self.saveBtn size:CGSizeMake(480, 48)];
    
    self.toolbarLine.padding = UIEdgeInsetsMake(4, 160, 4, 160);
    
//    [self.boxes addObject:self.cancelBtn];
//    [self.boxes addObject:self.saveBtn];
    
    [self.boxes addObject:self.toolbarLine];
    
    [self layoutWithSpeed:0.5 completion:nil];
    
    
    
    
    
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
