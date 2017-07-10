//
//  SAPageViewController.h
//  Dating Co
//
//  Created by SavvyApps on 9/2/15.
//  Copyright (c) 2015 Savvy Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAPageControlDisplay.h"

@protocol SAPageViewControllerDelegate;

@interface SAPageViewController : UICollectionViewController <SAPageControlDisplayDelegate>

@property(nullable, nonatomic, weak) id <SAPageViewControllerDelegate> delegate;

@property(nonatomic) BOOL showChildNavigationButtons;	//	Default is NO
@property(nonatomic) BOOL showChildNavigationTitle;	//	Default is NO
@property(nonatomic) BOOL showChildToolbarItems;	//	Default is YES

//	The default value is the value set in the collectionViewLayout.
@property(nonatomic) UICollectionViewScrollDirection scrollDirection;

@property(nonnull, nonatomic, copy) NSArray <__kindof UIViewController *> *viewControllers;

//	If you want to use the SAPageControlView you just have to do self.pageControl = [SAPageControlView new]
@property(nullable, nonatomic, strong) UIView <SAPageControlDisplay> *pageControl;

//	The currentViewController will be the view controller that is predominantly on the screen
@property(nullable, nonatomic, readonly) UIViewController *currentViewController;
@property(nonatomic, readonly) NSInteger currentIndex;

-(void)setViewControllers:(nullable NSArray <__kindof UIViewController *> *)viewControllers initialIndex:(NSInteger)index;

-(BOOL)scrollToNextViewController;
-(BOOL)scrollToPreviousViewController;

-(void)scrollToViewController:(nonnull UIViewController *)controller animated:(BOOL)animated;
-(void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated;

-(void)scrollViewDidFinishScrolling:(nonnull UIScrollView *)scrollView;

@end

@protocol SAPageViewControllerDelegate <NSObject>

-(void)pageViewController:(nonnull SAPageViewController *)controller didScrollToViewController:(nonnull UIViewController *)viewController index:(NSInteger)index;

@end

@interface UIViewController (SAPageViewController)

@property(nullable, nonatomic, readonly) SAPageViewController *pageViewController;

@property(nullable, nonatomic, strong) UIImage *pageIcon;
@property(nullable, nonatomic, strong) UIImage *pageIconSelected;

-(void)viewDidAppearInPageViewController;
-(void)viewWillDisappearInPageViewController;

-(void)navigationBarItemsDidChange;

@end