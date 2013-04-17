//
//  AnnotationsCoordinator.h
//  Footnotr
//
//  Created by Sam Homer on 4/13/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APAnnotations.h"
#import "APPDFInformation.h"

@interface ArticleCoordinator : NSObject
{
    
}

@property (strong, nonatomic) NSMutableDictionary *annotations;
@property (strong, nonatomic) NSMutableDictionary *articleInfo;


-(id) initWithArticle:(NSMutableDictionary *)articleInfo;

-(id) initWithArticle:(NSMutableDictionary *)articleInfo andAnnots:(NSMutableDictionary *)annots;

-(NSString *)articleAsJson;

-(NSString *)getXmlStringForAnnot:(APAnnotation *)annot withInfo:(APPDFInformation *)info;


@end
