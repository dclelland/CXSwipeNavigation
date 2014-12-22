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

@interface CXSwipeNavigationController () <UINavigationControllerDelegate, CXSwipeGestureRecognizerDelegate>

@property (nonatomic) CGFloat translationOffset;

- (CXSwipeGestureDirection)directionForOperation:(UINavigationControllerOperation)operation;
- (UINavigationControllerOperation)operationForDirection:(CXSwipeGestureDirection)direction;

@end

@interface CXSwipeGestureRecognizer (Private)

- (CGFloat)progressInDirection:(CXSwipeGestureDirection)direction withInitialOffset:(CGFloat)offset;

@end

@implementation CXSwipeNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationBarHidden = YES;
    self.delegate = self;
    
    self.swipeGestureRecognizer = [[CXSwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipe:)];
    self.swipeGestureRecognizer.delegate = self;
    
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

- (void)onSwipe:(CXSwipeGestureRecognizer *)gestureRecognizer
{
    /* If the interactive transition is not running */
    if (!self.swipeInteractiveTransition.transitioning) {
        
        switch ([self operationForDirection:gestureRecognizer.currentDirection]) {
            case UINavigationControllerOperationPush: {
                if (self.canPush && [(UIScrollView *)gestureRecognizer.view isScrolledToBottom]) {
                    [self pushViewController:[self.dataSource swipeNavigationController:self viewControllerAtIndex:self.viewControllers.count] animated:YES];
                    self.translationOffset = [gestureRecognizer translationInDirection:gestureRecognizer.currentDirection];
                }
                break;
            }
            case UINavigationControllerOperationPop: {
                if (self.canPop && [(UIScrollView *)gestureRecognizer.view isScrolledToTop]) {
                    [self popViewControllerAnimated:YES];
                    self.translationOffset = [gestureRecognizer translationInDirection:gestureRecognizer.currentDirection];
                }
                break;
            }
            default:
                break;
        }
        
    }
    
    /* If the interactive transition is running */
    if (self.swipeInteractiveTransition.transitioning) {
        
        switch (gestureRecognizer.state) {
                
                /* If the gesture has started, update the transition, or cancel it if the progress is less than zero */
            case UIGestureRecognizerStateBegan:
            case UIGestureRecognizerStateChanged: {
                CGFloat progress = [gestureRecognizer progressInDirection:[self directionForOperation:self.swipeTransition.operation] withInitialOffset:self.translationOffset];
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
                CGFloat translation = [gestureRecognizer translationInDirection:[self directionForOperation:self.swipeTransition.operation]];
                CGFloat velocity = [gestureRecognizer velocityInDirection:[self directionForOperation:self.swipeTransition.operation]];
                if (gestureRecognizer.state == UIGestureRecognizerStateCancelled || translation < self.translationThreshold || velocity < self.velocityThreshold) {
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
    [viewController.scrollView addGestureRecognizer:self.swipeGestureRecognizer];
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    self.swipeTransition.operation = operation;
    return self.swipeTransition;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.swipeInteractiveTransition;
}

#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return gestureRecognizer == self.swipeGestureRecognizer && otherGestureRecognizer == self.topViewController.scrollView.panGestureRecognizer;
}

#pragma mark - Private

- (UINavigationControllerOperation)operationForDirection:(CXSwipeGestureDirection)direction
{
    switch (direction) {
        case CXSwipeGestureDirectionUpwards:
            return UINavigationControllerOperationPush;
        case CXSwipeGestureDirectionDownwards:
            return UINavigationControllerOperationPop;
        default:
            return UINavigationControllerOperationNone;
    }
}

- (CXSwipeGestureDirection)directionForOperation:(UINavigationControllerOperation)operation
{
    switch (operation) {
        case UINavigationControllerOperationPush:
            return CXSwipeGestureDirectionUpwards;
        case UINavigationControllerOperationPop:
            return CXSwipeGestureDirectionDownwards;
        default:
            return CXSwipeGestureDirectionNone;
    }
}

@end

@implementation CXSwipeGestureRecognizer (Private)

- (CGFloat)progressInDirection:(CXSwipeGestureDirection)direction withInitialOffset:(CGFloat)offset
{
    return ([self translationInDirection:direction] - offset) / CGRectGetHeight(self.view.superview.frame);
}

@end
