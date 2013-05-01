//
//  AnnotationModel.m
//  Footnotr
//
//  Created by Sam Homer on 4/26/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "AnnotationModel.h"


@implementation AnnotationModel

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
