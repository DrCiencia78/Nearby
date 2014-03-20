//
//  Annotation.h
//  Nearby
//
//  Created by Agnt99 on 3/13/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Annotation : NSObject<MKAnnotation>

@property( nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


@end
