//
//  MapViewController.m
//  Nearby
//
//  Created by Agnt99 on 3/13/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Annotation.h"

@interface MapViewController (){
    
    CLLocationCoordinate2D center;
    
}

@end

@implementation MapViewController
@synthesize venueMapView,venuesArray,currentLatitude,currentLongitude;
float spanX = 0.0145;
float spanY = 0.0145;

MKCoordinateRegion myRegion;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self didCreateRegion];
    
    self.venueMapView.showsUserLocation = YES;
    self.venueMapView.delegate = self;
    [self didMapVenues];
    
}

-(void)viewWillAppear:(BOOL)animated{
 
    
}


-(void) didCreateRegion{
    
    //Coordinate2D Center
    
    center.latitude = currentLatitude;
    center.longitude = currentLongitude;
    
    //Create the Region
    
    myRegion.center.latitude = currentLatitude ;
    myRegion.center.longitude = currentLongitude;
    
    myRegion.span = MKCoordinateSpanMake(spanX, spanY);
    
    [self.venueMapView setRegion:myRegion animated:YES];
    
}

-(void)didMapVenues{
    
    NSMutableArray *venueLocations = [NSMutableArray new];
    
    for (id venue in venuesArray ) {
        Annotation *annotation = [Annotation new];
        CLLocationCoordinate2D location;
        
        location.longitude =  [[venue valueForKeyPath:@"location.lng"] doubleValue];
        location.latitude = [[venue valueForKeyPath:@"location.lat"] doubleValue];
        
        annotation.coordinate = location;
        annotation.title = [venue valueForKey:@"name"];
        annotation.subtitle = [venue valueForKeyPath:@"location.address"];
        
        [venueLocations addObject:annotation];
        
         
        
        
        
    }
    
    [self.venueMapView addAnnotations:venueLocations];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
