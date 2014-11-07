//
//  CXSwipeNavigationController.h
//  CALX
//
//  Created by Daniel Clelland on 20/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <CXSwipeGestureRecognizer/CXSwipeGestureRecognizer.h>

#import "CXSwipeTransition.h"
#import "CXSwipeInteractiveTransition.h"

@class CXSwipeNavigationController;

@protocol CXSwipeNavigationControllerDataSource

- (NSUInteger)numberOfViewControllersForSwipeNavigationController:(CXSwipeNavigationController *)navigationController;
- (UIViewController *)swipeNavigationController:(CXSwipeNavigationController *)navigationController viewControllerAtIndex:(NSUInteger)index;

@end

@interface CXSwipeNavigationController : UINavigationController

@property (nonatomic, strong) CXSwipeGestureRecognizer *swipeGestureRecognizer;

@property (nonatomic, strong) CXSwipeTransition *swipeTransition;
@property (nonatomic, strong) CXSwipeInteractiveTransition *swipeInteractiveTransition;

@property (nonatomic, weak) id <CXSwipeNavigationControllerDataSource> dataSource;

@property (nonatomic) CGFloat translationThreshold;
@property (nonatomic) CGFloat velocityThreshold;

- (BOOL)canPush;
- (BOOL)canPop;

@end
