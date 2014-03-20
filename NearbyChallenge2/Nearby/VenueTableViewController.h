//
//  VenueTableViewController.h
//  Nearby
//
//  Created by Agnt99 on 3/12/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreData/CoreData.h>
#import "VenueCell.h"
#import "MBProgressHUD.h"

@interface VenueTableViewController : UITableViewController<CLLocationManagerDelegate>

@property (strong,nonatomic) NSMutableArray * venuesForDisplayArray;

@property (strong, nonatomic) IBOutlet UITableView *venueTableView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic)     double currentLongitude;
@property (nonatomic)     double currentLatitude;

@end
