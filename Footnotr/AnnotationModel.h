//
//  AnnotationModel.h
//  Footnotr
//
//  Created by Sam Homer on 4/26/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APAnnotations.h"

@interface AnnotationModel : NSObject

@property(strong, nonatomic) APAnnotation *annot;
@property(strong, nonatomic) NSString *xml;
@property(assign, nonatomic) NSUInteger currPdfId;

-(NSString *)debugDescription;

@end
