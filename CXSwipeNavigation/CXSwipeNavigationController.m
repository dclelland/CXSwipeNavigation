//
//  CXSwipeNavigationController.m
//  CALX
//
//  Created by Daniel Clelland on 20/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <UIScrollView-Actions/UIScrollView+Actions.h>

#import "CXSwipeNavigationController.h"

#import "CXSwipeTableViewController.h"
#import "CXSwipeCollectionViewController.h"

#import "CXSwipeTransition.h"
#import "CXSwipeInteractiveTransition.h"

@interface CXSwipeNavigationController () <UINavigationControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic) CGFloat transitioningOffset;

@end

@interface UIPanGestureRecognizer (Private)

- (CGFloat)translationForOperation:(UINavigationControllerOperation)operation;
- (CGFloat)velocityForOperation:(UINavigationControllerOperation)operation;
- (CGFloat)progressForOperation:(UINavigationControllerOperation)operation withInitialOffset:(CGFloat)offset;

@end

@implementation CXSwipeNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBarHidden = YES;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.swipeTransition = [[CXSwipeTransition alloc] init];
    self.swipeInteractiveTransition = [[CXSwipeInteractiveTransition alloc] init];
}

#pragma mark - Overrides

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSAssert([viewController isKindOfClass:[CXSwipeTableViewController class]] || [viewController isKindOfClass:[CXSwipeCollectionViewController class]], @"Pushed view controller should inherit from either CXSwipeTableViewController or CXSwipeCollectionViewController");
    [super pushViewController:viewController animated:animated];
}

#pragma mark - Getters

- (BOOL)canPush
{
    return self.viewControllers.count < [self.dataSource numberOfViewControllersForSwipeNavigationController:self];
}

- (BOOL)canPop
{
    return self.viewControllers.count > 1;
}

#pragma mark - Actions

- (void)onPan:(UIPanGestureRecognizer *)gestureRecognizer
{
    /* If the interactive transition is not running */
    if (!self.swipeInteractiveTransition.transitioning) {
        
        /* Get the relevant data */
        CGPoint translation = [gestureRecognizer translationInView:self.view];
        CGPoint velocity = [gestureRecognizer velocityInView:self.view];
        UIScrollView *view = (UIScrollView *)gestureRecognizer.view;
        
        /* If scrolling downwards on a scrollview that is scrolled to the bottom, and can push, push a view controller */
        if (velocity.y < 0.0f && view.isScrolledToBottom && self.canPush) {
            [self pushViewController:[self.dataSource swipeNavigationController:self viewControllerAtIndex:self.viewControllers.count] animated:YES];
            self.transitioningOffset = -translation.y;
        }
        
        /* If scrolling upwards on a scrollview that is scrolled to the top, and can pop, pop a view controller */
        if (velocity.y > 0.0f && view.isScrolledToTop && self.canPop) {
            [self popViewControllerAnimated:YES];
            self.transitioningOffset = translation.y;
        }
    
    }
    
    /* If the interactive transition is running */
    if (self.swipeInteractiveTransition.transitioning) {
        
        switch (gestureRecognizer.state) {

            /* If the gesture has started, update the transition, or cancel it if the progress is less than zero */
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged: {
                CGFloat progress = [gestureRecognizer progressForOperation:self.swipeTransition.operation withInitialOffset:self.transitioningOffset];
                if (progress < 0.0f) {
                    [self.swipeInteractiveTransition cancelInteractiveTransition];
                } else {
                    [self.swipeInteractiveTransition updateInteractiveTransition:progress];
                }
                break;
            }
                
            /* If the gesture has finished, finish the transition, or cancel it if the velocity is less than zero */
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled: {
                CGFloat velocity = [gestureRecognizer velocityForOperation:self.swipeTransition.operation];
                if (gestureRecognizer.state == UIGestureRecognizerStateCancelled || velocity < 0.0f) {
                    [self.swipeInteractiveTransition cancelInteractiveTransition];
                } else {
                    [self.swipeInteractiveTransition finishInteractiveTransition];
                }
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - Navigation controller delegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController.scrollView.panGestureRecognizer addTarget:self action:@selector(onPan:)];
    
    viewController.scrollView.bounces = YES;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    self.swipeTransition.operation = operation;
    return self.swipeTransition;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.swipeInteractiveTransition;
}

@end

@implementation UIPanGestureRecognizer (Private)

- (CGFloat)translationForOperation:(UINavigationControllerOperation)operation
{
    switch (operation) {
        case UINavigationControllerOperationPush: return -[self translationInView:self.view.superview].y;
        case UINavigationControllerOperationPop: return [self translationInView:self.view.superview].y;
        default: return 0.0f;
    }
}

- (CGFloat)velocityForOperation:(UINavigationControllerOperation)operation
{
    switch (operation) {
        case UINavigationControllerOperationPush: return -[self velocityInView:self.view.superview].y;
        case UINavigationControllerOperationPop: return [self velocityInView:self.view.superview].y;
        default: return 0.0f;
    }
}

- (CGFloat)progressForOperation:(UINavigationControllerOperation)operation withInitialOffset:(CGFloat)offset
{
    return ([self translationForOperation:operation] - offset) / self.view.superview.frame.size.height;
}

@end
