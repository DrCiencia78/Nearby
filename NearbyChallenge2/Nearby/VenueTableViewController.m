//
//  VenueTableViewController.m
//  Nearby
//
//  Created by Agnt99 on 3/12/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import "VenueTableViewController.h"
#import "MapViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"


@interface VenueTableViewController (){
    
    CLLocationManager *locationManager;
    NSURLSessionConfiguration *config;
    
    Reachability *_reachability;
    NetworkStatus remoteHostStatus;
}

@end

@implementation VenueTableViewController
@synthesize venuesForDisplayArray, venueTableView,currentLatitude,currentLongitude;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    _reachability = [Reachability reachabilityForInternetConnection];
    remoteHostStatus = [_reachability currentReachabilityStatus];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [locationManager startUpdatingLocation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    
    [self.venueTableView reloadData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    UIColor *lightBlueColor = [UIColor colorWithRed:0.147 green:0.519 blue:0.810 alpha:1.000];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.navigationController.navigationBar.barTintColor = lightBlueColor;
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:@"MyFavoriteFont" size:20.0],
                                               NSFontAttributeName,
                                               nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchForNearbyVenues{
    
    
    
    if (remoteHostStatus != NotReachable)    {

        [self deleteAllObjects:@"LocationCD"];
        [self deleteAllObjects:@"VenueCD"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        
        NSString *locationURL =  [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=KVWAXF0SQXCBLFQOHSWYJSEDVI00VZCU0TW1I3BGFHTMP14W&client_secret=ZPN5QI0U55XOLRP5WPYSN4VBO3V3XKKHO2PXL3AWT1NYS50G&v=20130815&ll=%f,%f&intent=browse&radius=1000", currentLatitude,currentLongitude];
        
        config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:@"big.urlcache"];
        
        config.URLCache = cache;
        
        
        // NSURLSession *session = [NSURLSession sharedSession];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        [[session dataTaskWithURL:[NSURL URLWithString:locationURL]
                completionHandler:^(NSData *data, NSURLResponse *response,
                                    NSError *connectionError){
                    
                    NSDictionary *JSON = [ NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
                    
                    NSMutableDictionary *queryDictionary = [JSON objectForKey:@"response"];
                    NSMutableArray *venueArray = [queryDictionary objectForKey:@"venues"];
                    
                    
                    self.venuesForDisplayArray= [NSMutableArray new];
                    
                    
                    for (NSDictionary *venue in venueArray) {
                        
                        
                        NSManagedObject *localLocation = [NSEntityDescription insertNewObjectForEntityForName:@"LocationCD" inManagedObjectContext:self.managedObjectContext];
                        
                        NSDictionary *locationDictionary = [venue objectForKey:@"location"];
                        
                        [localLocation setValue:[locationDictionary objectForKey:@"lng"] forKey:@"lng"];
                        [localLocation setValue:[locationDictionary objectForKey:@"lat"] forKey:@"lat"];
                        [localLocation setValue:[locationDictionary objectForKey:@"address"] forKey:@"address"];
                        
                        NSString * meterDistance =[locationDictionary objectForKey:@"distance"];
                        
                        //convert meters to miles
                        double distance =  [meterDistance doubleValue] *  0.00062137;
                        
                        NSString * distanceMiles = [NSString stringWithFormat:@" %.2f miles away",distance];
                        
                        
                        NSManagedObject *localVenue = [NSEntityDescription insertNewObjectForEntityForName:@"VenueCD" inManagedObjectContext:self.managedObjectContext];
                        
                        //localVenue.name = [venue objectForKey:@"name"];
                        
                        [localVenue setValue:[venue objectForKey:@"name"] forKey:@"name"];
                        
                        [localLocation setValue:distanceMiles forKey:@"distance"];
                        [localVenue setValue:localLocation forKey:@"location"];
                        
                        NSArray *categoryArray = [venue objectForKey:@"categories"];
                        NSString *iconUrl;
                        NSString *category;
                        
                        for(NSDictionary *categoryDict in categoryArray) {
                            
                            NSDictionary *iconDict = [categoryDict objectForKey:@"icon"];
                            NSString *prefix = [iconDict objectForKey:@"prefix"];
                            NSString *suffix = [iconDict objectForKey:@"suffix"];
                            
                            category =[categoryDict objectForKey:@"shortName"];
                            iconUrl = [[prefix stringByAppendingString:@"64"] stringByAppendingString:suffix];
                            category =[categoryDict objectForKey:@"shortName"];
                            
                        }
                        
                        [localVenue setValue:category forKey:@"categoryName"];
                        
                        
                        [localVenue setValue:iconUrl forKey:@"iconURL"];
                        
                        
                        [self.venuesForDisplayArray addObject:localVenue];
                        
                        NSError *error = nil;
                        // Save the object to persistent store
                        if (![self.managedObjectContext save:&error]) {
                            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                        }
                        
                        
                    }
                    
                    // completionBlock();
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"location.distance" ascending:YES selector:@selector(compare:)];
                        [self.venuesForDisplayArray sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
                        
                        
                        NSLog(@"array %@",self.venuesForDisplayArray);
                        
                        [venueTableView reloadData];
                    }];
                    
                    
                }] resume];
        
    }
    else{ //No Network
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network" message:@"Last businesses found while network was available." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"hello, not net available");
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"VenueCD" inManagedObjectContext:self.managedObjectContext];
        
        // NSLog(@"entityDescription %@",entityDescription);
        
        NSFetchRequest *fetchRequest =[[NSFetchRequest alloc]init];
        NSFetchedResultsController *fetchedResultsController;
        NSError *error;
        
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"location.distance" ascending:YES selector:@selector(compare:)];
        NSArray *sortDescriptors;
        sortDescriptors = [NSArray arrayWithObject:sortDesc];
        
        fetchRequest.entity = entityDescription;
        
        //NSLog(@"fetchRequest %@",fetchRequest.entity);
        
        
        fetchRequest.sortDescriptors = sortDescriptors;
        NSLog(@" fetchRequest.sortDescriptors %@", fetchRequest.sortDescriptors);
        
        
        fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
        
        self.venuesForDisplayArray = [[context executeFetchRequest:fetchRequest error:nil]mutableCopy];
        
        // self.venuesForDisplayArray = fetchedResultsController.fetchedObjects.copy;
        NSLog(@" venueForDisplayArray %@",self.venuesForDisplayArray);
        
        [venueTableView reloadData];
        
        if (error) {
            NSLog(@"Error: %@",error);
            
        }
        
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        
        NSLog(@"currentLocation is not nil ");
        
        currentLatitude = currentLocation.coordinate.latitude;
        currentLongitude = currentLocation.coordinate.longitude;
        
    }
    
    
    [locationManager stopUpdatingLocation];
    [self searchForNearbyVenues];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return venuesForDisplayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    VenueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    // Configure the cell...
    
    id venue = [venuesForDisplayArray objectAtIndex:indexPath.row];
    
    cell.iconImage.clipsToBounds = YES;
    cell.iconImage.layer.cornerRadius = 8.0;
    cell.categoryImage.clipsToBounds = YES;
    cell.categoryImage.layer.cornerRadius = 8.0;
    
    
    [cell.iconImage setImageWithURL:[NSURL URLWithString:[venue valueForKey:@"iconURL"]]
                   placeholderImage:[UIImage imageNamed:@"default-image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                       NSLog(@"break");
                   }];
    
    [cell.categoryImage setImageWithURL:[NSURL URLWithString:[venue valueForKey:@"iconURL"]]
                   placeholderImage:[UIImage imageNamed:@"default-image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                       NSLog(@"break");
                   }];
    
    
    cell.nameLabel.textColor=[UIColor grayColor];
    cell.distanceLabel.textColor =[UIColor grayColor];
    cell.categoryLabel.textColor = [UIColor grayColor];
    
    //cell.nameLabel.text = venue.name;
    cell.nameLabel.text = [venue valueForKey:@"name"];
    
    
    cell.distanceLabel.text = [NSString stringWithFormat:@"%@", [venue valueForKeyPath:@"location.distance"]];
    //cell.categoryLabel.text = venue.categoryName;
    cell.categoryLabel.text = [venue valueForKey:@"categoryName"];
    
    // cell.imageView.
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

#pragma Delete All Objects in Core Data

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
    	[self.managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",entityDescription);
    }
    if (![_managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
    
    
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    MapViewController *mvc = [segue destinationViewController];
    mvc.venuesArray =self.venuesForDisplayArray;
    mvc.currentLongitude = currentLongitude;
    mvc.currentLatitude = currentLatitude;
    
    
    
}

#pragma mark Check for network activity



@end
