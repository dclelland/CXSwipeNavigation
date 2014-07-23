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

@property (nonatomic, retain) CXSwipeGestureRecognizer *swipeGestureRecognizer;

@property (nonatomic, retain) CXSwipeTransition *swipeTransition;
@property (nonatomic, retain) CXSwipeInteractiveTransition *swipeInteractiveTransition;

@property (unsafe_unretained) id <CXSwipeNavigationControllerDataSource> dataSource;

- (BOOL)canPush;
- (BOOL)canPop;

@end
