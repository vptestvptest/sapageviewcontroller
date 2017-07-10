//
//  SAPageControlDisplay.h
//  SAPageViewController
//
//  Created by Savvy Apps on 3/23/16.
//  Copyright © 2016 Emilio Peláez. All rights reserved.
//

#ifndef SAPageControlDisplay_h
#define SAPageControlDisplay_h

@protocol SAPageControlDisplayDelegate;

@protocol SAPageControlDisplay <NSObject>

@property(nullable, nonatomic, weak) id <SAPageControlDisplayDelegate> delegate;

@property(nonatomic, readonly) NSUInteger itemCount;
/**	Progress will be a number between -0.5 and itemCount-0.5, you should use this to determine how to display the current page */
@property(nonatomic) CGFloat progress;

-(void)configureWithViewControllers:(nonnull NSArray <__kindof UIViewController *> *)viewControllers;

@end

@protocol SAPageControlDisplayDelegate <NSObject>

-(void)pageControl:(nonnull UIView <SAPageControlDisplay> *)control didSelectItemAtIndex:(NSUInteger)index;

@end

#endif /* SAPageControlDisplay_h */
