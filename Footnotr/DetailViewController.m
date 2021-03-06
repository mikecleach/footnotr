
//  DetailViewController.m
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "DetailViewController.h"
#import "ArticleCoordinator.h"
#import "FPPopoverController.h"
#import "APIHttpClient.h" 
#import "UIControl+MGEvents.h"
#import "UserManager.h"
#import <Foundation/Foundation.h>
#import "FileMD5Hash.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"


@interface DetailViewController ()
{
    IBOutlet UIView *hostView;
    
    APPDFDocument *pdfDocument;
    APAnnotatingPDFViewController *pdfViewContr;
}


- (void)configureView;
@end

@implementation DetailViewController

-(id)initWithPDFDocument:(APPDFDocument *)document
{
    if (self = [super initWithNibName:@"PDFAnnotationSampleViewController" bundle:nil]) {
        NSAssert(nil != document, @"cannot initialize with nil document");
        pdfDocument = document;
    }
    return self;
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}


- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        
        self.navigationBar.title = [self.detailItem description];
        

        NSString *pdfPath = [self.documentDir stringByAppendingPathComponent:self.detailItem];
        
        //TODO:Cache the MD5 so we dont have to recalculate it each time a file is viewed.
        //In case we have large files, we use a file hashing function that uses CF to prevent ballooning autorelease pools.
        CFStringRef pdfFileMd5CF = FileMD5HashCreateWithPath((__bridge CFStringRef)pdfPath, 8096);

        //Get the md5 into a nice string, then release the CFStringRef
        NSString *pdfFileMd5 = (__bridge NSString *)pdfFileMd5CF;
        
        CFRelease(pdfFileMd5CF);
        
        
        NSString *articlePath = [NSString stringWithFormat: @"articles/%@/",pdfFileMd5];
        
        //Prepare a spinner so user know what's happening even if http req goes long
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = CGPointMake(hostView.center.x, hostView.center.y);
        spinner.color = [UIColor blueColor];
        [spinner startAnimating];
        [hostView addSubview:spinner];
        

        void (^getArticleBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
            
                
            NSError *error;
            self.article = [[ArticleModel alloc] initWithDictionary:JSON error:&error];
            
            //Now that annotations and associated xml is available, import the annotations to the pdf lib.
            NSArray *annotsModelArray = [self.article annots];
            
            BOOL importSuccessful = [self importAnnotsToPdfLib:annotsModelArray];
            
            if(!importSuccessful) {
                [self displayErrorAsAlert:@"Importing annotations to PDF library failed."];
            }
            
            //Since the imported annotations don't use the xml unique id they store, we have to reassociate the
            //imported annotations with their proper AnnotationModel instance. This is done by using the unix epoch
            //creationStamp time as a unique identifier that AnnotationModels store.
            NSArray *allLibAnnots = (NSArray *)[self.info allUserAnnotations];
            
            for (AnnotationModel *am in annotsModelArray) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"creationStamp == %d", am.pdfLibID];
                
                NSArray *matchingAnnot = [allLibAnnots filteredArrayUsingPredicate:predicate];
                
                am.annot = [matchingAnnot objectAtIndex:0];
                
            }
            
            //Since the annotations are imported and associated with our data model, we can initialize the pdf document
            APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:self.info];
            pdfDocument = pdfFile;
            
            /* create the view controller -- interactive on the iPad, read-only on the iPhone/iPod Touch... */
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                pdfViewContr = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfDocument];
            else
                pdfViewContr = (id)[[APPDFViewController alloc] initWithPDF:pdfDocument];
            
            
            pdfViewContr.delegate = self;
            
            pdfViewContr.viewOptions.pulsateActiveAnnotation = NO;
            /* ...and load it into the view hierarchy */
            //pdfView.view.frame = self.view.bounds;
            pdfViewContr.view.frame = hostView.bounds;
            pdfViewContr.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            //Cancel loading spinner
            [spinner removeFromSuperview];
            
            //If a pdf file is already in view, we need to remove the current views before adding the new view.
            [hostView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            
            [hostView addSubview:pdfViewContr.view];
            
            [pdfViewContr fitToWidth];
            
            //Create the annotation menu offscreen and lay it out.
            [self createNewAnnotationMenu];
                
        };
        
        void (^failedGetArticleBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Initial article request failed. This may be because the pdf has never been seen before and returned 'Not found'");
            NSLog([error localizedDescription]);
            NSLog([error localizedRecoverySuggestion]);
            
            //If not found was returned, it's a new article and we need to add it to the server
            if ([[error localizedRecoverySuggestion] rangeOfString:@"Not found"].length > 0 ) {
                
                UserManager *um = [UserManager sharedManager];
                UserModel *loggedInUser = [um loggedInUser];
                
                
                NSMutableDictionary *newArticle = [[NSMutableDictionary alloc] init];
                [newArticle setObject:pdfFileMd5 forKey:@"guid"];
                [newArticle setObject:[NSString stringWithFormat:@"%d", loggedInUser.pk] forKey:@"creator"];
                [newArticle setObject:self.detailItem forKey:@"title"];
                
                NSString *path = @"articles/new";
                [[APIHttpClient sharedClient] postPath:path parameters:newArticle success:getArticleBlock failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    //Cancel loading spinner
                    [spinner removeFromSuperview];
                    
                    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Article Request Failed" message:@"Server did not create article on server. Please try again."];
                    notice.delay = 4.0;
                    [notice show];
                }];
                
            }
            else {
                
                //Cancel loading spinner
                [spinner removeFromSuperview];
                
                WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Article Request Failed" message:@"Server did not return article data. Please try again."];
                notice.delay = 4.0;
                [notice show];
                
            }
        };
        
        //Send the request for the article's data
        [[APIHttpClient sharedClient] getPath:articlePath parameters:nil success:getArticleBlock  failure:failedGetArticleBlock];
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (!_documentDir) {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        _documentDir = [docPaths objectAtIndex:0];
    }
    
    //TODO: load last file loaded, even if app was terminated
    _detailItem = @"GettingStartedWithFootnotr.pdf";
    
    
    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    
    [hostView addGestureRecognizer:longTapRecognizer];
    
    [self configureView];
}

- (void)longTap:(UIGestureRecognizer *)gr
{
    //If no text was selected, don't start annotation mode.
    if ([pdfViewContr selectedText] == nil) {
        return;
    }
    
    [pdfViewContr addAnnotationOfType:kAPAnnotationTypeHighlight];
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didPlaceAnnotation:(APAnnotation *)annotation
{

    void (^createAnnotationBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        
        NSError *error;
        AnnotationModel *newAnnotModel = [[AnnotationModel alloc] initWithDictionary:JSON error:&error];
        
        //associate new annotation with annot model
        newAnnotModel.annot = annotation;
        
        [self.article addAnnotation:newAnnotModel];
        
    };
    
    
    void (^failedCreateAnnotationBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
    
        NSLog(@"***FAILED*** to create new annotation");
        //TODO:undo highlight or else expect crashes
        WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:@"Annotation Request Failed" message:@"Failed to save annotation. Please try again."];
        notice.delay = 4.0;
        [notice show];
    };
    
    //Create and populate a directory with the info neccesary to save it to server
    NSMutableDictionary *newAnnotDict = [[NSMutableDictionary alloc] init];
    
    NSString *annotAsXml = [self getXmlStringForAnnotation:annotation];
    [newAnnotDict setObject:annotAsXml forKey:@"xml"];
    
    int pdfLibID = (int)[(APTextMarkup *)annotation creationStamp];
    [newAnnotDict setObject:[NSString stringWithFormat:@"%d",pdfLibID] forKey:@"pdfLibID"];
    
    [newAnnotDict setObject:[NSString stringWithFormat:@"%d",self.article.pk] forKey:@"article"];
    
    UserManager *uManager = [UserManager sharedManager];
    UserModel *loggedInUser = uManager.loggedInUser;
    
    [newAnnotDict setObject:[NSString stringWithFormat:@"%d",loggedInUser.pk] forKey:@"user"];
    
    APIHttpClient *sharedClient = [APIHttpClient sharedClient];
    
    NSString *path = @"annotations/new";
    
    [sharedClient postPath:path parameters:newAnnotDict success:createAnnotationBlock failure:failedCreateAnnotationBlock];
}


-(void)pdfController:(APPDFViewController *)controller didTapOnAnnotation:(APAnnotation *)annotation inRect:(CGRect)rect
{

    CGRect annotViewRect = [pdfViewContr viewRectForPageSpaceRect:annotation.rect onPage:annotation.page];
    
    self.commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsViewController"];

    //get the annotation model associated with the tapped annotation, and set it's comments to the view controller.
    AnnotationModel *tappedAnnotModel = [self getAnnotModelForTimestampId:(int)[(APTextMarkup *)annotation creationStamp]];
    
    if (tappedAnnotModel == nil) {
        return;
    }
    
    self.commentsVC.annot = tappedAnnotModel;
    
    //initialize and present the popover
    FPPopoverController *pc = [[FPPopoverController alloc] initWithViewController:self.commentsVC];
    [pc setArrowDirection:FPPopoverArrowDirectionVertical];

    self.commentsVC.parentPopoverController = pc;
    
    //TODO:This feels hacky. Comments VC has to know way too much to achieve delete annotation functionality
    self.commentsVC.parentArticle = self.article;
    self.commentsVC.parentPdfInfo = self.info;
    self.commentsVC.parentPdfView = pdfViewContr;
    
    //TODO:Hardcoded layout stuff here
    pc.contentSize = CGSizeMake(380, 520);
    
    //FIXME:coordinates do not account for the 'Detail" Navigation Bar at top. Manually adjust for it here.
    //annotViewRect's origin is apparently not integer based, which can lead to uitextview aliasing issues so we round to a nice int value
    CGPoint adjustedOffset;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        adjustedOffset = CGPointMake(roundf(annotViewRect.origin.x+320),  roundf(annotViewRect.origin.y + 48));
    }
    else {
        adjustedOffset = CGPointMake(roundf(annotViewRect.origin.x),  roundf(annotViewRect.origin.y + 48));
    }
    
    [pc presentPopoverFromPoint:adjustedOffset];
    
}


- (UIColor *)pdfController:(APAnnotatingPDFViewController *)controller colorForNewAnnotationOfType:(APAnnotationType)annotType
{
    if (annotType == kAPAnnotationTypeHighlight) {
        return [UIColor colorWithRed:1 green:1 blue:0 alpha:1];
    }
    
    return nil;
}


- (BOOL)pdfController:(APAnnotatingPDFViewController *)controller shouldShowPopupForAnnotation:(APAnnotation *)annotation
{
    return NO;
}


- (void)createNewAnnotationMenu
{
    //Add new annotation menu
    self.annotCreationMenu = MGTableBoxStyled.box;
    self.annotCreationMenu.width = 200;
    
    self.annotCreationMenu.center = CGPointMake(hostView.width/2, -68);
    self.annotCreationMenu.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
    
    
    UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    
    //If user is done with annotation, tap this to finish and
    MGButton *doneBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, 24)];
    
    [doneBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    doneBtn.margin = UIEdgeInsetsMake(0, 20, 4, 20);
    
    //On tap this tells the pdfView controller to end editing mode. It also sends a message to the delegate(this controller), which is where we deal with saving to the server. See :didPlaceAnnotation.
    [doneBtn onControlEvent:UIControlEventTouchUpInside do:^{
        
        [pdfViewContr finishCurrentAnnotation];
    }];
    
    
    MGButton *cancelBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, 24)];
    
    
    [cancelBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelBtn.margin = UIEdgeInsetsMake(0, 20, 4, 20);
    
    //Similarly to Done, this tells the View controller to cancel editing annot.
    [cancelBtn onControlEvent:UIControlEventTouchUpInside do:^{
        
        [pdfViewContr cancelAddAnnotation];
    }];
    
    MGLine *buttonsLine = [MGLine lineWithLeft:cancelBtn right:doneBtn size:CGSizeMake(200, 30)];
    
    
    MGLineStyled *addAnnotHeader = [MGLineStyled lineWithLeft:@"Add New Annotation" right:nil size:CGSizeMake(200, 30)];
    addAnnotHeader.padding = UIEdgeInsetsMake(0, 27, 0, 0);
    
    
    [self.annotCreationMenu.topLines addObject:addAnnotHeader];
    [self.annotCreationMenu.bottomLines addObject:buttonsLine];
    
    [self.annotCreationMenu setContentLayoutMode:MGLayoutGridStyle];
    
    self.annotCreationMenu.margin = UIEdgeInsetsMake(4, 20, 4, 20);

    [self.annotCreationMenu layout];
    
    
    [hostView addSubview:self.annotCreationMenu];
}


- (void)pdfController:(APAnnotatingPDFViewController *)controller didEnterAnnotationMode:(APAnnotationType)type
{
    [UIView animateWithDuration:0.7 animations:^{
    
        self.annotCreationMenu.center = CGPointMake(hostView.width/2, 34);
    }];
}


- (void)pdfController:(APAnnotatingPDFViewController *)controller didEndAnnotationMode:(APAnnotationType)type
{
    [UIView animateWithDuration:0.7 animations:^{
        
        self.annotCreationMenu.center = CGPointMake(hostView.width/2, -34);
    }];
}


-(AnnotationModel *)getAnnotModelForTimestampId:(int)tsId
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pdfLibID == %d", tsId];
    
    NSArray *matchingAnnot = [self.article.annots filteredArrayUsingPredicate:predicate];
    
    //this can happen if user taps a new annotation before the creation request has successfully returned.
    if (!matchingAnnot.count) {
        return nil;
    }
    
    return [matchingAnnot objectAtIndex:0];
}


-(NSInputStream *)packageAnnotationsIntoXml:(NSArray *)annotsModelArray
{
    //PDF information library-required header and footer
    NSString *xmlHeader = @"<annotations>\n";
    NSString *xmlFooter = @"</annotations>";
    
    //packaging annots into xml string for importing to PDFInfo object
    NSMutableData *packagedXml = [[NSMutableData alloc] initWithData:[xmlHeader dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    for (AnnotationModel *am in annotsModelArray) {
        [packagedXml appendData:[am.xml dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [packagedXml appendData:[xmlFooter dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [[NSInputStream alloc] initWithData:packagedXml];
}

//initialize the pdfInformation object as a memory database, package the annots into xml form, and import them
- (BOOL)importAnnotsToPdfLib:(NSArray *)annotsModelArray
{
    
    self.info = [[APPDFInformation alloc] initAsMemoryDatabase];
    
    NSInputStream *is = [self packageAnnotationsIntoXml:annotsModelArray];
    
    BOOL importSuccess = [self.info importAnnotationXMLFromStream:is];
    
    return importSuccess;
}


- (NSString *)getXmlStringForAnnotation:(APAnnotation *)annot
{
    
    NSOutputStream *os = [[NSOutputStream alloc] initToMemory];
    
    [self.info exportSingleAnnotationXML:annot toStream:os];
    
    NSData *annotationAsData =  [os propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    NSString *outputString = [[NSString alloc] initWithData:annotationAsData encoding:NSUTF8StringEncoding];
    
    return outputString;
}


- (void)displayErrorAsAlert:(id)error
{
    if([error isKindOfClass:[NSError class]]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"" otherButtonTitles:nil] show];
    }
    else if ([error isKindOfClass:[NSString class]]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:self cancelButtonTitle:@"" otherButtonTitles:nil] show];
    }
}


-(BOOL)pdfController:(APPDFViewController *)controller shouldShowRibbonForAnnotation:(APAnnotation *)annotation
{
    return NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [pdfViewContr viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [pdfViewContr viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [pdfViewContr viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [pdfViewContr viewWillDisappear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (nil == pdfViewContr ? YES : [pdfViewContr shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pdfViewContr willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [pdfViewContr didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"File Browser", @"File Browser");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
