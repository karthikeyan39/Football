//
//  CutomTableViewCell.m
//  Football
//
//  Created by Manoj Prasad on 06/11/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import "CutomTableViewCell.h"

@implementation CutomTableViewCell
@synthesize homeNameLbl,homeGoalLbl,statusLbl,dateLbl,awayGoalLbl,awayNameLbl;
@synthesize containerView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
