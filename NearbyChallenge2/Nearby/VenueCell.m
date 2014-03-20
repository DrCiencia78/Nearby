//
//  VenueCell.m
//  VenueSearch
//
//  Created by Agnt99 on 3/11/14.
//  Copyright (c) 2014 Agnt99. All rights reserved.
//

#import "VenueCell.h"

@implementation VenueCell
@synthesize nameLabel, distanceLabel, categoryLabel, iconImage, categoryImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
