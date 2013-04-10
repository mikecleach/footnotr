//
//  DetailViewController.m
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
@end

@implementation DetailViewController

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
    }
    
    NSString *pdfPath = [self.documentDir stringByAppendingPathComponent:self.detailItem];
    
    NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *infoFileName = [self.detailItem stringByAppendingString:@".info"];
    NSString *infoPath = [[libPaths objectAtIndex:0] stringByAppendingPathComponent:infoFileName];
    
    /* create the PDF information object; this will load the cached
     * file if it exists, or prepare it if it does not yet exist. */
    APPDFInformation *info = [[APPDFInformation alloc] initWithPath:infoPath];
    
    /* now the APPDFDocument object */
    APPDFDocument *pdfFile = [[APPDFDocument alloc] initWithPath:pdfPath information:info];
    
    
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
    
}


-(id)initWithPDFDocument:(APPDFDocument *)document
{
    if (self = [super initWithNibName:@"PDFAnnotationSampleViewController" bundle:nil]) {
        NSAssert(nil != document, @"cannot initialize with nil document");
        pdfDocument = document;    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (!_documentDir) {
        NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        _documentDir = [docPaths objectAtIndex:0];
    }
    
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
