//
//  UIAlertView+Blocks.m
//  Vienna
//
//  Created by Kyle Crum on 2/10/13.
//  Copyright (c) 2013 Adelante Web Productions, LLC. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

@interface UIAlertView (BlocksInternal)

    @property (nonatomic,copy) AWPAlertViewClickedBlock clickedBlock;
    @property (nonatomic, copy) AWPAlertViewCancelBlock cancelBlock;

@end

NSString * const kAWPAlertViewClickedBlockKey = @"kAWPAlertViewClickedBlockKey";
NSString * const kAWPAlertViewCancelBlockKey = @"kAWPAlertViewCancelBlockKey";

@implementation UIAlertView (Blocks)

-(void)showWithBlock:(AWPAlertViewClickedBlock)clickedBlock cancelBlock:(AWPAlertViewCancelBlock)cancelBlock
{
    self.delegate = self;
    self.clickedBlock = clickedBlock;
    self.cancelBlock = cancelBlock;
    [self show];
}

- (void)setClickedBlock:(id)aObject
{
    objc_setAssociatedObject(self, (__bridge const void *)(kAWPAlertViewClickedBlockKey), [aObject copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)clickedBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kAWPAlertViewClickedBlockKey));
}

- (void)setCancelBlock:(id)aObject
{
    objc_setAssociatedObject(self, (__bridge const void *)(kAWPAlertViewCancelBlockKey), [aObject copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)cancelBlock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(kAWPAlertViewCancelBlockKey));
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.clickedBlock) {
        self.clickedBlock(buttonIndex);
    }
}

-(void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

@end
