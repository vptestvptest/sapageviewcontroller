//
//  SAPageControlView.h
//  Dating Co
//
//  Created by SavvyApps on 9/2/15.
//  Copyright (c) 2015 Savvy Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAPageControlDisplay.h"

@protocol SAPageControlViewDelegate;

@interface SAPageControlView : UIView <SAPageControlDisplay>

@property(nonatomic, weak) id <SAPageControlDisplayDelegate> delegate;

@property(nonatomic) CGFloat progress;

//	Default is 32x32
@property(nonatomic) CGSize iconSize;

//	If any of these colors is not nil, the images will be colorized with that color.
//	If you set them from non-nil to nil, you'll need to re-set the icon images
//	(This happens automatically when using SAPageViewController)
//	Images will not be colorized when the rendering mode is UIImageRenderingModeAlwaysOriginal
@property(nonatomic, strong) UIColor *unselectedColor;
@property(nonatomic, strong) UIColor *selectedColor;

//	If you don't want your images to be colorized make sure the rendering mode is UIImageRenderingModeAlwaysOriginal
-(void)setIconImages:(NSArray <UIImage *> *)iconImages selectedIconImages:(NSArray <UIImage *> *)selectedIconImages;

@end


@interface UIImage (SAColorize)

-(UIImage *)sa_imageColorizedWithColor:(UIColor *)color;

@end