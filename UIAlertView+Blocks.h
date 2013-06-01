//
//  UIAlertView+Blocks.h
//  Vienna
//
//  Created by Kyle Crum on 2/10/13.
//  Copyright (c) 2013 Adelante Web Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AWPAlertViewClickedBlock)(NSInteger buttonIndex);
typedef void (^AWPAlertViewCancelBlock)(void);

@interface UIAlertView (Blocks)

-(void)showWithBlock:(AWPAlertViewClickedBlock)clickedBlock cancelBlock:(AWPAlertViewCancelBlock)cancelBlock;

@end
