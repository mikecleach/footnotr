//
//  AnnotationModel.h
//  Footnotr
//
//  Created by Sam Homer on 4/26/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APAnnotations.h"
#import "CommentModel.h"

@protocol AnnotationModel

@end

@interface AnnotationModel : JSONModel

@property(strong, nonatomic) APAnnotation<Optional> *annot;
@property(strong, nonatomic) NSString *xml;
@property int pdfLibID;
@property(strong, nonatomic) NSArray<CommentModel> *comments;
@property(strong, nonatomic) NSString *url;

-(NSString *)debugDescription;

@end