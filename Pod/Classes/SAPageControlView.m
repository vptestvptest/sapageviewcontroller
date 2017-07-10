//
//  SAPageControlView.m
//  Dating Co
//
//  Created by SavvyApps on 9/2/15.
//  Copyright (c) 2015 Savvy Apps. All rights reserved.
//

#import "SAPageControlView.h"
#import "SAPageViewController.h"

@interface SAPageControlView (){
	UITapGestureRecognizer *tapRecognizer;
	
	NSArray *originalIconImages;
	NSArray *originalSelectedIconImages;
}

@property(nonatomic) NSUInteger itemCount;

@property(nonatomic, readonly) NSArray *iconImages;
@property(nonatomic, readonly) NSArray *selectedIconImages;

-(void)initializeView;
-(void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer;

@end

@implementation SAPageControlView

-(instancetype)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	if(self){
		[self initializeView];
	}
	return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
	self = [super initWithCoder:aDecoder];
	if(self){
		[self initializeView];
	}
	return self;
}

-(void)initializeView{
	self.backgroundColor = [UIColor clearColor];
	
	self.iconSize = CGSizeMake(32, 32);
	
	tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recognizeTapGesture:)];
	[self addGestureRecognizer:tapRecognizer];
}

-(void)recognizeTapGesture:(UITapGestureRecognizer *)recognizer{
	CGFloat x = [recognizer locationInView:recognizer.view].x;
	
	NSUInteger index = (NSUInteger)(x / self.iconSize.width);
	[self.delegate pageControl:self didSelectItemAtIndex:MAX(0, MIN(self.itemCount - 1, index))];
}

-(void)configureWithViewControllers:(nonnull NSArray <__kindof UIViewController *> *)viewControllers{
	self.itemCount = viewControllers.count;
	
	NSMutableArray *iconImages = [NSMutableArray arrayWithCapacity:self.itemCount];
	NSMutableArray *selectedIconImages = [NSMutableArray arrayWithCapacity:self.itemCount];
	[viewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop) {
		UIImage *icon = vc.pageIcon ? vc.pageIcon : [UIImage new];
		
		[iconImages addObject:icon];
		[selectedIconImages addObject:vc.pageIconSelected ? vc.pageIconSelected : icon];
	}];
	
	originalIconImages = iconImages;
	originalSelectedIconImages = selectedIconImages;
	[self updateIconImages];
}

-(void)updateIconImages{
	[self setIconImages:originalIconImages selectedIconImages:originalSelectedIconImages];
}

-(void)setIconImages:(NSArray *)iconImages selectedIconImages:(NSArray *)selectedIconImages{
	if(iconImages.count != selectedIconImages.count || iconImages.count != self.itemCount)
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Invalid image arrays" userInfo:nil];
	
	if(self.unselectedColor){
		NSMutableArray *temp = [NSMutableArray arrayWithCapacity:iconImages.count];
		[iconImages enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
			if(image.renderingMode == UIImageRenderingModeAlwaysOriginal)
				[temp addObject:image];
			else
				[temp addObject:[image sa_imageColorizedWithColor:self.unselectedColor]];
		}];
		_iconImages = [temp copy];
	}else{
		_iconImages = [iconImages copy];
	}
	
	if(self.selectedColor){
		NSMutableArray *temp = [NSMutableArray arrayWithCapacity:selectedIconImages.count];
		[selectedIconImages enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
			if(image.renderingMode == UIImageRenderingModeAlwaysOriginal)
				[temp addObject:image];
			else
				[temp addObject:[image sa_imageColorizedWithColor:self.selectedColor]];
		}];
		_selectedIconImages = [temp copy];
	}else{
		_selectedIconImages	= [selectedIconImages copy];
	}
	
	[self setNeedsDisplay];
}

-(void)setProgress:(CGFloat)progress{
	_progress = progress;
	[self setNeedsDisplay];
}

-(void)setIconSize:(CGSize)iconSize{
	_iconSize = iconSize;
	
	[self setNeedsDisplay];
	[self sizeToFit];
}

-(void)setItemCount:(NSUInteger)itemCount{
	_itemCount = itemCount;
	
	_iconImages = nil;
	_selectedIconImages = nil;
	
	[self sizeToFit];
}

-(void)setUnselectedColor:(UIColor *)unselectedColor{
	_unselectedColor = unselectedColor;
	
	[self updateIconImages];
}

-(void)setSelectedColor:(UIColor *)selectedColor{
	_selectedColor = selectedColor;
	
	[self updateIconImages];
}

-(void)drawRect:(CGRect)rect {
	CGSize expectedSize = CGSizeMake(self.itemCount * self.iconSize.width, self.iconSize.height);
	if(!CGSizeEqualToSize(expectedSize, rect.size)) @throw [NSException exceptionWithName:NSInternalInconsistencyException
																																								 reason:[NSString stringWithFormat:@"Invalid size (%@, expected: %@), use sizeToFit", NSStringFromCGSize(rect.size), NSStringFromCGSize(expectedSize)]
																																							 userInfo:nil];
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGFloat offset = (rect.size.width - self.iconSize.width) * _progress / (self.itemCount - 1);
	
	CGContextSaveGState(c);
	
	CGContextAddRect(c, CGRectMake(0, 0, offset, rect.size.height));
	CGContextAddRect(c, CGRectMake(offset + self.iconSize.height, 0, rect.size.width - (offset + self.iconSize.height), rect.size.height));
	CGContextClip(c);
	
	if(!self.iconImages) return;
	for(int i = 0; i < self.itemCount; i++){
		CGRect imageRect = CGRectMake(self.iconSize.width * i, 0, self.iconSize.width, self.iconSize.height);
		CGPoint center = CGPointMake(CGRectGetMidX(imageRect), CGRectGetMidY(imageRect));
		UIImage *image = self.iconImages[i];
		[image drawAtPoint:CGPointMake(center.x - image.size.width / 2, center.y - image.size.height / 2)];
	}
	CGContextRestoreGState(c);
	
	CGContextSaveGState(c);
	CGContextAddRect(c, CGRectMake(offset, 0, self.iconSize.width, self.iconSize.height));
	CGContextClip(c);
	
	for(int i = 0; i < self.itemCount; i++){
		CGRect imageRect = CGRectMake(self.iconSize.width * i, 0, self.iconSize.width, self.iconSize.height);
		CGPoint center = CGPointMake(CGRectGetMidX(imageRect), CGRectGetMidY(imageRect));
		UIImage *image = self.selectedIconImages[i];
		[image drawAtPoint:CGPointMake(center.x - image.size.width / 2, center.y - image.size.height / 2)];
	}
	
	CGContextRestoreGState(c);
}

-(void)sizeToFit{
	[self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.itemCount * self.iconSize.width, self.iconSize.height)];
}

@end

@implementation UIImage (SAColorize)

-(UIImage *)sa_imageColorizedWithColor:(UIColor *)color{
	UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect drawRect = CGRectZero;
	drawRect.size = self.size;
	
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	[self drawInRect:drawRect];
	
	CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	[color setFill];
	CGContextFillRect(context, drawRect);
	
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return result;
}

@end