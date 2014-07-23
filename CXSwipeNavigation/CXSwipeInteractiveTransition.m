//
//  CXSwipeInteractiveTransition.m
//  CALX
//
//  Created by Daniel Clelland on 20/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import "CXSwipeInteractiveTransition.h"

@implementation CXSwipeInteractiveTransition

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    [super startInteractiveTransition:transitionContext];
    self.transitioning = YES;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    [super updateInteractiveTransition:MIN(MAX(percentComplete, 0.0f), 1.0f)];
}

- (void)cancelInteractiveTransition
{
    [super cancelInteractiveTransition];
    self.transitioning = NO;
}

- (void)finishInteractiveTransition
{
    [super finishInteractiveTransition];
    self.transitioning = NO;
}

- (CGFloat)completionSpeed
{
    return powf(self.percentComplete, 2.0f) - self.percentComplete + 0.75f;
}

@end
