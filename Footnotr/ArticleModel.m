//
//  ArticleModel.m
//  Footnotr
//
//  Created by Sam Homer on 4/30/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "ArticleModel.h"

@implementation ArticleModel

- (void)addAnnotation:(AnnotationModel *)annotToAdd
{
    [self.annots addObject:annotToAdd];
}


- (void) removeAnnotation:(AnnotationModel *)annotToRemove
{
    [self.annots removeObject:annotToRemove];
    
}

@end
