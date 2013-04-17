//
//  AnnotationsCoordinator.m
//  Footnotr
//
//  Created by Sam Homer on 4/13/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "ArticleCoordinator.h"


@implementation ArticleCoordinator

- (id)initWithArticle:(NSMutableDictionary *)articleInfo
{
    if (self = [super init]) {
        NSAssert(nil != articleInfo, @"cannot initialize with nil article dict");
        self.articleInfo = articleInfo;
    }
    return self;
}

- (id)initWithArticle:(NSMutableDictionary *)articleInfo andAnnots:(NSMutableDictionary*)annots
{
    if (self = [super init]) {
        
        NSAssert(nil != articleInfo, @"cannot initialize with nil article dict");
        self.articleInfo = articleInfo;
        
        NSAssert(nil != annots, @"cannot initialize with nil annots dict");
        self.annotations = annots;
    }
    return self;
}

- (NSString *)articleAsJson
{
    
    NSMutableDictionary *outerJsonContainer = [[NSMutableDictionary alloc] initWithDictionary:self.articleInfo];
    
    [outerJsonContainer setObject:self.annotations forKey:@"annots"];
    
    
    NSError *error;
    NSData *jsonAnnots = [NSJSONSerialization dataWithJSONObject:outerJsonContainer options:kNilOptions error:&error];
    
    if (!error)
        return [[NSString alloc] initWithData:jsonAnnots encoding:NSUTF8StringEncoding];
    return @"Error";
    
}

//The output stream blocks on writing so be careful in using this!
-(NSString *)getXmlStringForAnnot:(APAnnotation *)annot withInfo:(APPDFInformation *)info
{
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    [os setDelegate:os];
    [os open];
    BOOL exported = [info exportSingleAnnotationXML:annot toStream:os];
    
    NSData *annotXml = [os propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    [os close];
    
    return [[NSString alloc] initWithData:annotXml encoding:NSUTF8StringEncoding];
    

}



@end
