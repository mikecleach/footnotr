//
//  AppDelegate.h
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AjiPDFLib.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    APLibrary * library;
}
@property (strong, nonatomic) UIWindow *window;

@end
