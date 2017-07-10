//
//  SAPageViewController.m
//  Dating Co
//
//  Created by SavvyApps on 9/2/15.
//  Copyright (c) 2015 Savvy Apps. All rights reserved.
//

#import "SAPageViewController.h"
#import "SAPageControlView.h"
#import <objc/runtime.h>
#import "SAViewControllerCollectionViewCell.h"

@interface SAPageViewController (){
	CGSize lastFrameSize;
	CGSize lastContentSize;
	UIEdgeInsets lastContentInset;
	
	BOOL subviewsLaidout;
	NSInteger initialIndex;
	
	NSInteger lastBarUpdateIndex;
	
	BOOL isKeyboardShowing;
	CGPoint offsetBeforeKeyboard;
}

-(void)initializeController;

-(void)configurePageControl;
-(void)configureLayout;

-(void)updateBarItems:(BOOL)animated;

-(CGFloat)progress;

-(void)willShowKeyboardNotification:(NSNotification *)notification;
-(void)willHideKeyboardNotification:(NSNotification *)notification;

@end

@interface UIViewController (SAPageViewControllerPrivate)

@property(nonatomic, weak) SAPageViewController *pageViewController;

@end

@implementation SAPageViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - Object Life cycle

-(instancetype)init{
	self = [super init];
	if(self){
		[self initializeController];
	}
	return self;
}

-(instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
	if(![layout isKindOfClass:UICollectionViewFlowLayout.class]) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Unsupported layout class" userInfo:nil];
	self = [super initWithCollectionViewLayout:layout];
	if(self){
		[self initializeController];
	}
	return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
	self = [super initWithCoder:aDecoder];
	if(self){
		[self initializeController];
	}
	return self;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if(self){
		[self initializeController];
	}
	return self;
}

-(void)initializeController{
	lastFrameSize = CGSizeZero;
	subviewsLaidout = NO;
	initialIndex = -1;
	
	_viewControllers = [NSArray new];
	
	lastBarUpdateIndex = -1;
	
	_showChildNavigationButtons = NO;
	_showChildNavigationTitle = NO;
	_showChildToolbarItems = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
	[_viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		vc.pageViewController = nil;
		[vc removeObserver:self forKeyPath:NSStringFromSelector(@selector(pageIcon))];
		[vc removeObserver:self forKeyPath:NSStringFromSelector(@selector(pageIconSelected))];
	}];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Life cycle

-(void)viewDidLoad{
	[super viewDidLoad];
	
	[self.collectionView registerClass:SAViewControllerCollectionViewCell.class forCellWithReuseIdentifier:reuseIdentifier];
	
	self.collectionView.pagingEnabled = YES;
	self.collectionView.showsHorizontalScrollIndicator =
	self.collectionView.showsVerticalScrollIndicator =
	NO;
}

-(void)viewDidLayoutSubviews{
	[super viewDidLayoutSubviews];
	
	[self configureLayout];
	
	if(!subviewsLaidout){
		subviewsLaidout = YES;
		[self.collectionView reloadData];
		
		//	This forces the collection view to size correctly
		CGSize __unused size = self.collectionView.collectionViewLayout.collectionViewContentSize;
		if(initialIndex != -1)
			[self scrollToViewControllerAtIndex:initialIndex animated:NO];
	}
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
	[self updateBarItems:NO];
}

#pragma mark - Configure View

-(void)configureLayout{
	if(CGSizeEqualToSize(self.view.frame.size, lastFrameSize) &&
		 CGSizeEqualToSize(self.collectionView.contentSize, lastContentSize) &&
		 UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, lastContentInset))
		return;
	
	lastFrameSize = self.view.frame.size;
	lastContentSize = self.collectionView.contentSize;
	lastContentInset = self.collectionView.contentInset;
	
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
	CGRect bounds = self.collectionView.bounds;
	UIEdgeInsets contentInset = self.collectionView.contentInset;
	CGSize itemSize;
	switch (self.scrollDirection) {
  case UICollectionViewScrollDirectionHorizontal:
			itemSize = CGSizeMake(bounds.size.width, bounds.size.height - (contentInset.top + contentInset.bottom));
			break;
		case UICollectionViewScrollDirectionVertical:
			itemSize = CGSizeMake(bounds.size.width - (contentInset.left + contentInset.right), bounds.size.height);
			break;
	}
	
	layout.itemSize =
	layout.estimatedItemSize =
	itemSize;
	
	layout.minimumInteritemSpacing =
	layout.minimumLineSpacing =
	0;
	
	layout.sectionInset = UIEdgeInsetsZero;
	
	for(int i = 0; i < self.viewControllers.count; i++){
		UIViewController *viewController = self.viewControllers[i];
		viewController.view.frame = CGRectMake(0, 0, itemSize.width, itemSize.height);
		[viewController.view layoutIfNeeded];
	}
}

-(void)configurePageControl{
	[self.pageControl configureWithViewControllers:self.viewControllers];
	
	if(self.pageControl == self.navigationItem.titleView)
		[self.pageControl sizeToFit];
}

-(void)updateBarItems:(BOOL)animated{
	if(self.showChildNavigationButtons){
		[self.navigationItem setLeftBarButtonItems:self.currentViewController.navigationItem.leftBarButtonItems animated:animated];
		[self.navigationItem setRightBarButtonItems:self.currentViewController.navigationItem.rightBarButtonItems animated:animated];
	}
	if(self.showChildNavigationTitle){
		if(self.currentViewController.navigationItem.titleView) self.navigationItem.titleView = self.currentViewController.navigationItem.titleView;
		else self.navigationItem.title = self.currentViewController.navigationItem.title;
	}
	if(self.showChildToolbarItems){
		[self setToolbarItems:self.currentViewController.toolbarItems animated:animated];
	}
}

#pragma mark - Navigation

-(BOOL)scrollToNextViewController{
	if(self.currentIndex < self.viewControllers.count - 1){
		[self scrollToViewControllerAtIndex:self.currentIndex + 1 animated:YES];
		return YES;
	}
	return NO;
}

-(BOOL)scrollToPreviousViewController{
	if(self.currentIndex > 0){
		[self scrollToViewControllerAtIndex:self.currentIndex - 1 animated:YES];
		return YES;
	}
	return NO;
}

-(void)scrollToViewController:(UIViewController *)controller animated:(BOOL)animated{
	NSInteger index = [self.viewControllers indexOfObject:controller];
	if(index == NSNotFound)
		@throw [NSException exceptionWithName:NSInternalInconsistencyException
																	 reason:@"View controller not contained in viewControllers array"
																 userInfo:@{@"ViewController" : controller,
																						@"ViewControllers" : self.viewControllers}];
	
	[self scrollToViewControllerAtIndex:index animated:animated];
}

-(void)scrollToViewControllerAtIndex:(NSInteger)index animated:(BOOL)animated{
	if(index < 0 || index >= self.viewControllers.count)
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invalid index" userInfo:nil];
	
	[self.currentViewController viewWillDisappearInPageViewController];
	
	if(index == self.currentIndex) return;
	if(isKeyboardShowing) {
		NSLog(@"Please dismiss the keyboard before trying to scroll to another page");
		return;
	}
	
	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
															atScrollPosition:self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically
																			animated:animated];
}

#pragma mark - Properties

-(void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
	layout.scrollDirection = scrollDirection;
	
	[self scrollViewDidScroll:self.collectionView];
}

-(UICollectionViewScrollDirection)scrollDirection{
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
	return layout.scrollDirection;
}

-(void)setViewControllers:(nonnull NSArray <__kindof UIViewController *> *)viewControllers{
	if(!viewControllers) viewControllers = [NSArray new];
	
	[_viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		vc.pageViewController = nil;
		[vc removeObserver:self forKeyPath:NSStringFromSelector(@selector(pageIcon))];
		[vc removeObserver:self forKeyPath:NSStringFromSelector(@selector(pageIconSelected))];
		[vc removeFromParentViewController];
	}];
	
	_viewControllers = [viewControllers copy];
	
	[_viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		vc.pageViewController = self;
		[vc addObserver:self forKeyPath:NSStringFromSelector(@selector(pageIcon)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
		[vc addObserver:self forKeyPath:NSStringFromSelector(@selector(pageIconSelected)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
		[self addChildViewController:vc];
	}];
	
	[self configurePageControl];
	[self updateBarItems:NO];
	
	[self.collectionView reloadData];
}

-(void)setViewControllers:(nullable NSArray <__kindof UIViewController *> *)viewControllers initialIndex:(NSInteger)index{
	[self setViewControllers:viewControllers];
	
	initialIndex = index;
	
	if(subviewsLaidout){
		[self scrollToViewControllerAtIndex:initialIndex animated:NO];
	}
}

-(void)setPageControl:(UIView<SAPageControlDisplay> *)pageControl{
	_pageControl = pageControl;
	
	pageControl.delegate = self;
	
	[self configurePageControl];
}

-(UIViewController *)currentViewController{
	if(_viewControllers.count == 0) return nil;
	return self.viewControllers[self.currentIndex];
}

-(NSInteger)currentIndex{
	return (NSInteger)round(self.progress);
}

-(CGFloat)progress{
	switch (self.scrollDirection) {
		case UICollectionViewScrollDirectionHorizontal:
			return self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
		case UICollectionViewScrollDirectionVertical:
			return self.collectionView.contentOffset.y / self.collectionView.frame.size.height;
	}
}

-(void)willShowKeyboardNotification:(NSNotification *)notification{
	isKeyboardShowing = YES;
	offsetBeforeKeyboard = self.collectionView.contentOffset;
}

-(void)willHideKeyboardNotification:(NSNotification *)notification{
	isKeyboardShowing = NO;
}

#pragma mark - SAPageControlViewDelegate

-(void)pageControl:(SAPageControlView *)control didSelectItemAtIndex:(NSUInteger)index{
	[self scrollToViewControllerAtIndex:index animated:YES];
}

#pragma mark - CollectionViewDataSource / CollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
	return subviewsLaidout ? 1 : 0;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
	return self.viewControllers.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
	SAViewControllerCollectionViewCell *cell = (id)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
	cell.viewController = self.viewControllers[indexPath.row];
	
	return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
	[self configureLayout];
	return [(UICollectionViewFlowLayout *)collectionViewLayout itemSize];
}

#pragma mark - ScrollViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
	[self.currentViewController viewWillDisappearInPageViewController];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
	if (isKeyboardShowing)
		scrollView.contentOffset = offsetBeforeKeyboard;
	
	self.pageControl.progress = self.progress;
	
	[self updateBarItems:YES];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	if(!decelerate) {
		[self scrollViewDidFinishScrolling:scrollView];
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
	[self scrollViewDidFinishScrolling:scrollView];
}

-(void)scrollViewDidFinishScrolling:(UIScrollView *)scrollView{
	[self.delegate pageViewController:self didScrollToViewController:self.currentViewController index:self.currentIndex];
	[self.currentViewController viewDidAppearInPageViewController];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	if([keyPath isEqualToString:NSStringFromSelector(@selector(pageIcon))] ||
		 [keyPath isEqualToString:NSStringFromSelector(@selector(pageIconSelected))])
		[self configurePageControl];
}

@end

@implementation UIViewController (SAPageViewController)
@dynamic pageViewController;
@dynamic pageIcon, pageIconSelected;

-(void)setPageViewController:(SAPageViewController *)pageViewController{
	objc_setAssociatedObject(self, @selector(pageViewController), pageViewController, OBJC_ASSOCIATION_ASSIGN);
}

-(SAPageViewController *)pageViewController{
	return objc_getAssociatedObject(self, @selector(pageViewController));
}

-(void)setPageIcon:(UIImage *)pageIcon{
	objc_setAssociatedObject(self, @selector(pageIcon), pageIcon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImage *)pageIcon{
	return objc_getAssociatedObject(self, @selector(pageIcon));
}

-(void)setPageIconSelected:(UIImage *)pageIconSelected{
	objc_setAssociatedObject(self, @selector(pageIconSelected), pageIconSelected, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIImage *)pageIconSelected{
	return objc_getAssociatedObject(self, @selector(pageIconSelected));
}

-(void)viewDidAppearInPageViewController{}

-(void)viewWillDisappearInPageViewController{}

-(void)navigationBarItemsDidChange{
	[self.pageViewController updateBarItems:YES];
}

@end