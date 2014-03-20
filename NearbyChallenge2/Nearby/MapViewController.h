//
//  MapViewController.h
//  Nearby
//
//  Created by Agnt99 on 3/13/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VenueCell.h"
#import "MBProgressHUD.h"


@interface MapViewController : UIViewController <MKMapViewDelegate,MKAnnotation>

@property (strong,nonatomic)NSMutableArray *venuesArray;

@property (weak, nonatomic) IBOutlet MKMapView *venueMapView;
@property (nonatomic)     double currentLongitude;
@property (nonatomic)     double currentLatitude;
@end
