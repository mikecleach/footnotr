
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
        
        //   THIS CODE IS FOR LOADING ARTICLE INFORMATION FROM A WEBSITE
        
        //FIXME: article api call is hardcoded
        [[APIHttpClient sharedClient] getPath:@"articles/1/" parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {

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
            NSString *pdfPath = [self.documentDir stringByAppendingPathComponent:self.detailItem];
            APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:self.info];
            pdfDocument = pdfFile;
            
            /* create the view controller -- interactive on the iPad, read-only on the iPhone/iPod Touch... */
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                pdfViewContr = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfDocument];
            else
                pdfViewContr = (id)[[APPDFViewController alloc] initWithPDF:pdfDocument];
            
            
            pdfViewContr.delegate = self;
            
            /* ...and load it into the view hierarchy */
            //pdfView.view.frame = self.view.bounds;
            pdfViewContr.view.frame = hostView.bounds;
            pdfViewContr.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            //If a pdf file is already in view, we need to remove the current views before adding the new view.
            [hostView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            
            [hostView addSubview:pdfViewContr.view];
            
            [pdfViewContr fitToWidth];
            
            
            
            //Add new annotation menu
            self.annotCreationMenu = [MGBox boxWithSize:CGSizeMake(200, 0)];
            
            //self.annotCreationMenu.frame = CGRectMake(0, -40, 200, 40);
            
            self.annotCreationMenu.center = CGPointMake(hostView.width/2, -40);
            self.annotCreationMenu.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.95 alpha:1];
            
            
            UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                                    resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
            
            MGButton *doneBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];

            [doneBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
            doneBtn.margin = UIEdgeInsetsMake(4, 20, 4, 20);

            [doneBtn onControlEvent:UIControlEventTouchUpInside do:^{
                
                [pdfViewContr finishCurrentAnnotation];
            }];
            
            
            
            MGButton *cancelBtn = [[MGButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
            
            
            [cancelBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
            [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            cancelBtn.margin = UIEdgeInsetsMake(4, 20, 4, 20);
            
            [cancelBtn onControlEvent:UIControlEventTouchUpInside do:^{
            
                [pdfViewContr cancelAddAnnotation];
            }];
            [self.annotCreationMenu.boxes addObject:cancelBtn];
            [self.annotCreationMenu.boxes addObject:doneBtn];
            
            [self.annotCreationMenu setContentLayoutMode:MGLayoutGridStyle];
            
            self.annotCreationMenu.margin = UIEdgeInsetsMake(4, 20, 4, 20);
            
            //self.annotCreationMenu.sizingMode = MGResizingExpandWidthToFill;
            
            [self.annotCreationMenu layout];
            
            
            [hostView addSubview:self.annotCreationMenu];
            
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self displayErrorAsAlert:error];
        }];
        
        //   END REMOTE LOADING OF ARTICLE INFORMATION
    
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
    
    //FIXME:Stop autoloading test pdf
    _detailItem = @"test.pdf";
    
    
    UILongPressGestureRecognizer *longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTap:)];
    
    [hostView addGestureRecognizer:longTapRecognizer];
    
    [self configureView];
}

- (void)longTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Long tap detected on pdf's hostview");
    [pdfViewContr addAnnotationOfType:kAPAnnotationTypeHighlight];
}

-(void)pdfController:(APAnnotatingPDFViewController *)controller didPlaceAnnotation:(APAnnotation *)annotation
{
    //get the annotations creation time and current identifier and store to mapping dictionary
    NSLog(@"pdf lib did create annotation");
    
    
    void (^createAnnotationBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        
        
        NSError *error;
        AnnotationModel *newAnnotModel = [[AnnotationModel alloc] initWithDictionary:JSON error:&error];
        
        //associate new annotation with annot model
        newAnnotModel.annot = annotation;
        
        [self.article addAnnotation:newAnnotModel];
        
    };
    
    
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
    
    [sharedClient postPath:path parameters:newAnnotDict success:createAnnotationBlock failure:nil];
}


-(void)pdfController:(APPDFViewController *)controller didTapOnAnnotation:(APAnnotation *)annotation inRect:(CGRect)rect
{

    CGRect annotViewRect = [pdfViewContr viewRectForPageSpaceRect:annotation.rect onPage:annotation.page];
    
    self.commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsViewController"];

    //get the annotation model associated with the tapped annotation, and set it's comments to the view controller.
    AnnotationModel *tappedAnnotModel = [self getAnnotModelForTimestampId:(int)[(APTextMarkup *)annotation creationStamp]];
    
    self.commentsVC.annot = tappedAnnotModel;
    
    //initialize and present the popover
    FPPopoverController *pc = [[FPPopoverController alloc] initWithViewController:self.commentsVC];
    
    
    self.commentsVC.parentPopoverController = pc;
    
    //TODO:This feels hacky. Comments VC has to know way too much to achieve delete annotation functionality
    self.commentsVC.parentArticle = self.article;
    self.commentsVC.parentPdfInfo = self.info;
    self.commentsVC.parentPdfView = pdfViewContr;
    
    pc.contentSize = CGSizeMake(380, 520);
    
    //FIXME:coordinates do not account for the 'Detail" Navigation Bar at top. Manually adjust for it here.
    //annotViewRect's origin is apparently not integer based, which can lead to uitextview aliasing issues so we round to a nice int value
    CGPoint adjustedOffset = CGPointMake(roundf(annotViewRect.origin.x),  roundf(annotViewRect.origin.y + 48));
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

- (void)pdfController:(APAnnotatingPDFViewController *)controller didEnterAnnotationMode:(APAnnotationType)type
{
    [UIView animateWithDuration:0.7 animations:^{
    
        self.annotCreationMenu.center = CGPointMake(hostView.width/2, 20);
    }];
}

- (void)pdfController:(APAnnotatingPDFViewController *)controller didEndAnnotationMode:(APAnnotationType)type
{
    [UIView animateWithDuration:0.7 animations:^{
        
        self.annotCreationMenu.center = CGPointMake(hostView.width/2, -20);
    }];
}


-(AnnotationModel *)getAnnotModelForTimestampId:(int)tsId
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pdfLibID == %d", tsId];    
    
    NSArray *matchingAnnot = [self.article.annots filteredArrayUsingPredicate:predicate];
    
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
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
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
