//
//  WeatheTableViewCell.m
//  GCDExample
//
//  Created by Manjula Jonnalagadda on 1/19/15.
//  Copyright (c) 2015 Manjula Jonnalagadda. All rights reserved.
//

#import "WeatheTableViewCell.h"

@interface WeatheTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTempLabel;

@end

@implementation WeatheTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCity:(NSString *)city minTemp:(NSString *)minTemp maxTemp:(NSString *)maxTemp{
    
    _cityLabel.text=city;
    _minTempLabel.text=minTemp;
    _maxTempLabel.text=maxTemp;
    
}

@end
