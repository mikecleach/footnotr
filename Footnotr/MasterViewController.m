//
//  MasterViewController.m
//  Footnotr
//
//  Created by Sam Homer on 3/27/13.
//  Copyright (c) 2013 Sam Homer. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];

    
    self.detailViewController.documentDir = documentsDir;
    
    
    //Load some default documents from the bundle to the user's documents directory
    NSString *recipeFilePath = [NSString stringWithFormat:@"%@%@", documentsDir, @"Chicken_Thighs_with_Shallots_in_Red_Wine_Vinegar.pdf"];
    
    NSString *lectureFilePath = [NSString stringWithFormat:@"%@%@", documentsDir, @"ECE361-Lecture1-DiscreteNatureOfInformation.pdf"];
    
        NSString *gettingStartedFilePath = [NSString stringWithFormat:@"%@%@", documentsDir, @"GettingStartedWithFootnotr.pdf"];
    
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Copy the recipe pdf to the documents dir if it doesn't exist
    NSString *saveFilePath = [documentsDir stringByAppendingPathComponent:@"Chicken_Thighs_with_Shallots_in_Red_Wine_Vinegar.pdf"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:recipeFilePath] == NO)
        [fileManager createDirectoryAtPath:recipeFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [fileManager copyItemAtPath:[bundle pathForResource:@"Chicken_Thighs_with_Shallots_in_Red_Wine_Vinegar" ofType:@"pdf"] toPath:saveFilePath error:NULL];
    

    //Copy the lecture pdf to the documents dir if it doesn't exist
    saveFilePath = [documentsDir stringByAppendingPathComponent:@"ECE361-Lecture1-DiscreteNatureOfInformation.pdf"];
    if ([fileManager fileExistsAtPath:lectureFilePath] == NO)
        [fileManager createDirectoryAtPath:lectureFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [fileManager copyItemAtPath:[bundle pathForResource:@"ECE361-Lecture1-DiscreteNatureOfInformation" ofType:@"pdf"] toPath:saveFilePath error:NULL];
    
    //Copy the getting started pdf to the documents dir if it doesn't exist
    saveFilePath = [documentsDir stringByAppendingPathComponent:@"GettingStartedWithFootnotr.pdf"];
    if ([fileManager fileExistsAtPath:gettingStartedFilePath] == NO)
        [fileManager createDirectoryAtPath:gettingStartedFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    
    [fileManager copyItemAtPath:[bundle pathForResource:@"GettingStartedWithFootnotr" ofType:@"pdf"] toPath:saveFilePath error:NULL];
    
    
    NSError *error;
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:&error];
    
    NSString *match = @".pdf";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF endswith %@", match];
    NSArray *results = [docs filteredArrayUsingPredicate:predicate];
    
    if (!_objects) {
        _objects = [[NSMutableArray alloc] initWithArray:results];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"in master view's view did appear");
    
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [docPaths objectAtIndex:0];
    
    NSError *error;
    NSArray *docs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error:&error];
    
    NSString *match = @".pdf";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF endswith %@", match];
    NSArray *results = [docs filteredArrayUsingPredicate:predicate];

    _objects = [[NSMutableArray alloc] initWithArray:results];
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSString *pdfFileName = _objects[indexPath.row];
        self.detailViewController.detailItem = pdfFileName;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
