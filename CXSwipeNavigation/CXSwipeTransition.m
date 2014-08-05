//
//  CXSwipeTransition.m
//  CALX
//
//  Created by Daniel Clelland on 20/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <UIScrollView-Actions/UIScrollView+Actions.h>

#import "CXSwipeTransition.h"

@implementation CXSwipeTransition

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operation = UINavigationControllerOperationNone;
        _duration = 0.333;
        _gutter = 0.0f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    NSAssert(self.operation != UINavigationControllerOperationNone, @"CXSwipeTransition should have a valid operation set");
    
    /* Get the view controllers */
    UITableViewController *fromViewController = (UITableViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UITableViewController *toViewController = (UITableViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    /* Get the container */
    UIView *container = [transitionContext containerView];
    
    /* Add the views to the container */
    [container addSubview:fromViewController.view];
    [container addSubview:toViewController.view];
    
    /* Calculate the various transformations */
    CGRect sourceRect = [transitionContext initialFrameForViewController:fromViewController];
    
    CGAffineTransform animationTransform;
    
    CGAffineTransform upTransform = CGAffineTransformMakeTranslation(0.0f, -sourceRect.size.height - self.gutter);
    CGAffineTransform downTransform = CGAffineTransformMakeTranslation(0.0f, sourceRect.size.height + self.gutter);
    
    /* Decide which transformations to use */
    switch (self.operation) {
        case UINavigationControllerOperationPush: {
            animationTransform = upTransform;
            toViewController.view.frame = CGRectApplyAffineTransform(toViewController.view.frame, downTransform);
            break;
        }
        case UINavigationControllerOperationPop: {
            animationTransform = downTransform;
            toViewController.view.frame = CGRectApplyAffineTransform(toViewController.view.frame, upTransform);
            break;
        }
        default: break;
    }
    
    /* Scroll the view controllers to the appropriate positions */
    switch (self.operation) {
        case UINavigationControllerOperationPush: {
            [toViewController.scrollView scrollToTopAnimated:NO];
            [fromViewController.scrollView scrollToBottomAnimated:NO];
            break;
        }
        case UINavigationControllerOperationPop: {
            [toViewController.scrollView scrollToBottomAnimated:NO];
            [fromViewController.scrollView scrollToTopAnimated:NO];
            break;
        }
        default: break;
    }
    
    /* Animate the transition */
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void){
        
        /* Apply the transition */
        container.transform = animationTransform;
        
        /* Disable scrolling */
        fromViewController.scrollView.scrollEnabled = NO;
        toViewController.scrollView.scrollEnabled = NO;
        
    } completion:^(BOOL finished){
        
        /* Finish the transitions */
        container.transform = CGAffineTransformIdentity;
        toViewController.view.frame = sourceRect;
        
        /* Reenable scrolling */
        fromViewController.scrollView.scrollEnabled = YES;
        toViewController.scrollView.scrollEnabled = YES;
        
        /* Tidy everything up according to whether the transition completed or not */
        if ([transitionContext transitionWasCancelled]) {
            [toViewController.view removeFromSuperview];
            [transitionContext completeTransition:NO];
        } else {
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }
        
    }];
}

@end
