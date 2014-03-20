//
//  VenueCell.h
//  VenueSearch
//
//  Created by Agnt99 on 3/11/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;

@end
