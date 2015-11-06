//
//  CutomTableViewCell.h
//  Football
//
//  Created by Manoj Prasad on 06/11/15.
//  Copyright (c) 2015 example. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CutomTableViewCell : UITableViewCell
@property(nonatomic,strong) IBOutlet UIView *containerView;
@property(nonatomic,strong)IBOutlet UILabel *homeNameLbl,*awayNameLbl,*statusLbl,*dateLbl,*homeGoalLbl,*awayGoalLbl;
@end
