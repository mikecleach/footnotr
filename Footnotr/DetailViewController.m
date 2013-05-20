//
//  DetailViewController.m
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "DetailViewController.h"
#import "ArticleCoordinator.h"
#import "ArticleModel.h"
#import "FPPopoverController.h"
#import "APIHttpClient.h" 
#import <Foundation/Foundation.h>


@interface DetailViewController ()
{
    IBOutlet UIView *hostView;
    
    APPDFDocument *pdfDocument;
    APAnnotatingPDFViewController *pdfView;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableData *serverResponse;
@property (strong, nonatomic) APPDFInformation *info;
@property (strong, nonatomic) ArticleModel *article;

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
                pdfView = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfDocument];
            else
                pdfView = (id)[[APPDFViewController alloc] initWithPDF:pdfDocument];
            
            //FIXME: make this support annotating protocol so next line is used.
            pdfView.delegate = self;
            
            /* ...and load it into the view hierarchy */
            //pdfView.view.frame = self.view.bounds;
            pdfView.view.frame = hostView.bounds;
            pdfView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            [hostView addSubview:pdfView.view];
            
            [pdfView fitToWidth];
            
            
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
    
    _detailItem = @"test.pdf";
    
    [self configureView];
}


-(void)pdfController:(APAnnotatingPDFViewController *)controller didCreateAnnotation:(APAnnotation *)annotation
{
    //get the annotations creation time and current identifier and store to mapping dictionary
}

-(void)pdfController:(APPDFViewController *)controller didTapOnAnnotation:(APAnnotation *)annotation inRect:(CGRect)rect
{
    //FIXME:popover has an offset, probably due to the Detail Text bar at top of split view
    CGRect annotViewRect = [pdfView viewRectForPageSpaceRect:annotation.rect onPage:annotation.page];
    
    self.commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsViewController"];

    //get the annotation model associated with the tapped annotation, and set it's comments to the view controller.
    AnnotationModel *tappedAnnotModel = [self getAnnotModelForTimestampId:(int)[(APTextMarkup *)annotation creationStamp]];
    
    self.commentsVC.comments = tappedAnnotModel.comments;
    
    //initialize and present the popover
    FPPopoverController *pc = [[FPPopoverController alloc] initWithViewController:self.commentsVC];
    
    pc.contentSize = CGSizeMake(400, 500);
    
    //FIXME:coordinates do not account for the 'Detail" Navigation Bar at top. Manually adjust for it here.
    CGPoint adjustedOffset = CGPointMake(annotViewRect.origin.x,  annotViewRect.origin.y + 48);
    [pc presentPopoverFromPoint:adjustedOffset];
    
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
    [pdfView viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [pdfView viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [pdfView viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [pdfView viewWillDisappear:animated];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (nil == pdfView ? YES : [pdfView shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pdfView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [pdfView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
