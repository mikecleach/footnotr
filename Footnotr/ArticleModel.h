//
//  ArticleModel.h
//  Footnotr
//
//  Created by Sam Homer on 4/30/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "JSONModel.h"
#import "AnnotationModel.h"

@interface ArticleModel : JSONModel

@property(strong,nonatomic) NSString *title;
@property(strong,nonatomic) NSString *creator;
@property(strong,nonatomic) NSArray<AnnotationModel>* annots;

@end
