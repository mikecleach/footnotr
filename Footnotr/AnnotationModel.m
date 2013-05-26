//
//  AnnotationModel.m
//  Footnotr
//
//  Created by Sam Homer on 4/26/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "AnnotationModel.h"


@implementation AnnotationModel

- (void)addComment:(CommentModel *)commentToAdd
{
    [self.comments addObject:commentToAdd];
    
    //TODO:trigger add object event here, so ui knows to update??
}

- (void)removeComment:(CommentModel *)commentToRemove
{
    [self.comments removeObject:commentToRemove];
}

-(NSString *) description
{
    return [self debugDescription];
}

-(NSString *) debugDescription
{
    NSMutableString *desc = [NSMutableString string];

    [desc appendString: ((APTextMarkup *)self.annot).markupText.length > 10 ? [((APTextMarkup *)self.annot).markupText substringToIndex:10] : ((APTextMarkup *)self.annot).markupText ];
    
    [desc appendString:@"  xml:"];
    
    [desc appendString: [self.xml substringToIndex:60]];
    
    [desc appendString:@"  pdfLibID:"];
    
    [desc appendString:[NSString stringWithFormat:@"%d", self.pdfLibID]];
    
    
    return [desc copy];
}

@end
