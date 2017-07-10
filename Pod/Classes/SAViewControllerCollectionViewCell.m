//
//  SAViewControllerCollectionViewCell.m
//  Dating Co
//
//  Created by SavvyApps on 9/2/15.
//  Copyright (c) 2015 Savvy Apps. All rights reserved.
//

#import "SAViewControllerCollectionViewCell.h"

@implementation SAViewControllerCollectionViewCell

-(void)setViewController:(UIViewController *)viewController{
	if(_viewController.view.superview == self.contentView)
		[_viewController.view removeFromSuperview];
	
	_viewController = viewController;

	[self.contentView addSubview:viewController.view];
    
	[self layoutIfNeeded];
}

-(void)layoutSubviews{
	[super layoutSubviews];
	
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	
	self.viewController.view.frame = self.bounds;
}

@end
