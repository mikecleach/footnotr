//
//  DetailViewController.m
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "DetailViewController.h"
#import "ArticleCoordinator.h"
#import "FPPopoverController.h"


@interface DetailViewController ()
{
    IBOutlet UIView *hostView;
    
    APPDFDocument *pdfDocument;
    APAnnotatingPDFViewController *pdfView;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSMutableData *serverResponse;
@property (strong, nonatomic) APPDFInformation *info;
@property (strong, nonatomic) ArticleCoordinator *ac;
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
    
    
        NSString *pdfPath = [self.documentDir stringByAppendingPathComponent:self.detailItem];
        
        NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *infoFileName = [self.detailItem stringByAppendingString:@".info"];
        NSString *infoPath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:infoFileName];
        
        /* create the PDF information object; this will load the cached
         * file if it exists, or prepare it if it does not yet exist. */
        self.info = [[APPDFInformation alloc] initAsMemoryDatabase];
        
        /* now the APPDFDocument object */
        //APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:self.info];
        
        
        
        //   THIS CODE IS FOR LOADING ARTICLE INFORMATION FROM A WEBSITE
        
        NSURL * url = [NSURL URLWithString:@"http://127.0.0.1:8000/article/1/"];
        
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"GET"];
        
        //when request returns, it is proceesed in connection:didRecieveData
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        //   END REMOTE LOADING OF ARTICLE INFORMATION
        
        
        
        //   THIS CODE IS FOR BUILDING ARTICLE INFO FROM A LOADED INFORMATION FILE //
//        NSArray *annots = [pdfFile.information allUserAnnotations];
//        NSMutableDictionary *indexedAnnots = [[NSMutableDictionary alloc] init];
//        //building a dictionary of Annotation objects with unique numeric id key
//        for(id annot in annots) {
//            [indexedAnnots setObject:annot forKey:[NSString stringWithFormat:@"%i",[pdfFile.information identifierForAnnotation:annot]]];
//        }
//        
//        
//        NSDictionary *articleInfo = @{
//                                @"title": @"test.pdf",
//                                @"articleId": @"1"
//                                };
//        
//        //first we initialize ac with just article info because the annotation data must be gotten via helper method
//        ArticleCoordinator *ac = [[ArticleCoordinator alloc] initWithArticle:articleInfo];
//        
//        //building a serializable version of annotations keyed via unique, hopefully the same as before, key
//        NSMutableDictionary *annotXml = [[NSMutableDictionary alloc] init];
//        for (NSString *key in indexedAnnots) {
//            NSDictionary* xmlDict = @{
//                                @"xmlStr" : [ac getXmlStringForAnnot:[indexedAnnots objectForKey:key] withInfo:info]
//                                };
//            [annotXml setObject:xmlDict forKey:key];
//        }
//        
//
//        //article object is fully formed after this, so we can ask for json representation
//        ac.annotations = annotXml;
//        
//        
//        NSString *jsonOut = [ac articleAsJson];
        //    END BUILDING OF ARTICLE INFO

        

        //pdfDocument = pdfFile;
        /* create and launch the view controller */
        //    PDFAnnotationSampleViewController * pdfView = [[PDFAnnotationSampleViewController alloc] initWithPDFDocument:pdfFile];
        
        
        /* create the view controller -- interactive on the iPad, read-only on the iPhone/iPod Touch... */
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//            pdfView = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfDocument];
//        else
//            pdfView = (id)[[APPDFViewController alloc] initWithPDF:pdfDocument];
//        //fixme: make this support annotating protocol so next line is used.
//        pdfView.delegate = self;
//        
//        /* ...and load it into the view heirarchy */
//        //pdfView.view.frame = self.view.bounds;
//        pdfView.view.frame = hostView.bounds;
//        pdfView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//        [hostView addSubview:pdfView.view];
//        
        //[pdfView fitToWidth];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No Annots Found! Web server on?" delegate:self cancelButtonTitle:@"" otherButtonTitles:nil] show];
    }
}


-(NSInputStream *) packageAnnotationsIntoXml:(NSDictionary *)annotsData
{
    //PDF information library-required header and footer
    NSString *xmlHeader = @"<annotations>\n";
    NSString *xmlFooter = @"</annotations>";
    

    //packaging annots into xml string for importing to PDFInfo object
    NSMutableData *packagedXml = [[NSMutableData alloc] initWithData:[xmlHeader dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    for (NSString *key in annotsData) {
        NSDictionary *xmlObj = [annotsData objectForKey:key];
        [packagedXml appendData:[[xmlObj objectForKey:@"xmlStr"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [packagedXml appendData:[xmlFooter dataUsingEncoding:NSUTF8StringEncoding]];
    
    return [[NSInputStream alloc] initWithData:packagedXml];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    //NSData *json = [[NSData alloc] initWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Article data comes packed as dictionaries within a dictionary: articleInfo, annots, comments are the keys
    NSError *error;
    NSDictionary *articleData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    
    NSDictionary *annotsData = [articleData objectForKey:@"annots"];
    
    NSInputStream *is = [self packageAnnotationsIntoXml:annotsData];
    
    [self.info importAnnotationXMLFromStream:is];

    
    self.ac = [[ArticleCoordinator alloc] initWithArticle:[articleData objectForKey:@"articleInfo"]];
    
    self.ac.comments = [articleData objectForKey:@"comments"];
    
    
    
    //NSDictionary *fields = [theobj objectForKey:@"fields"];
    
    //NSLog(@"theobj: %@", fields);
    NSString *pdfPath = [self.documentDir stringByAppendingPathComponent:self.detailItem];
    APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:self.info];
    pdfDocument = pdfFile;
    /* create and launch the view controller */
    //    PDFAnnotationSampleViewController * pdfView = [[PDFAnnotationSampleViewController alloc] initWithPDFDocument:pdfFile];
    
    
    /* create the view controller -- interactive on the iPad, read-only on the iPhone/iPod Touch... */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        pdfView = [[APAnnotatingPDFViewController alloc] initWithPDF:pdfDocument];
    else
        pdfView = (id)[[APPDFViewController alloc] initWithPDF:pdfDocument];
    //fixme: make this support annotating protocol so next line is used.
    pdfView.delegate = self;
    
    /* ...and load it into the view heirarchy */
    //pdfView.view.frame = self.view.bounds;
    pdfView.view.frame = hostView.bounds;
    pdfView.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [hostView addSubview:pdfView.view];
    
    [pdfView fitToWidth];
    
    
    [self.serverResponse appendData:data];
}

-(void)connection:(NSURLConnection *)connection {
    // do what you want with myClassPointerData the data that your server did send you back here
    // for info on your server php script you just need to do: echo json_encode(array('var1'=> $var1, 'var2'=>$var2...));
    // to get your server sending an answer
}


-(void)pdfController:(APPDFViewController *)controller didTapOnAnnotation:(APAnnotation *)annotation inRect:(CGRect)rect
{
    CGRect annotViewRect = [pdfView viewRectForPageSpaceRect:annotation.rect onPage:annotation.page];
    //NSString *comments = []
    UITextView *commentsView = [[UITextView alloc] initWithFrame:CGRectMake(0, annotViewRect.origin.y, 60, 60)];
    [commentsView setText:@"Test comment 1"];
    [commentsView setEditable:NO];
    //[pdfView.view addSubview:commentsView];
    
    //self.commentsVC
    //CommentsViewController *commVC = [[CommentsViewController alloc] init];
    
    
    // do any setup you need for myNewVC
    
    self.commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsViewController"];
    
    
    
    FPPopoverController *pc = [[FPPopoverController alloc] initWithViewController:self.commentsVC];
    
    [pc presentPopoverFromPoint:annotViewRect.origin];
    
}

-(BOOL)pdfController:(APPDFViewController *)controller shouldShowRibbonForAnnotation:(APAnnotation *)annotation
{
    return NO;
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
