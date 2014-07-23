//
//  CXSwipeCollectionViewController.m
//  CALX
//
//  Created by Daniel Clelland on 23/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <UIScrollView-Actions/UIScrollView+Actions.h>

#import "CXSwipeCollectionViewController.h"
#import "CXSwipeNavigationController.h"

@interface CXSwipeCollectionViewController ()

- (CXSwipeNavigationController *)swipeNavigationController;

@end

@implementation CXSwipeCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.bounces = YES;
}

#pragma mark - Getters

- (CXSwipeNavigationController *)swipeNavigationController
{
    if ([self.navigationController isKindOfClass:[CXSwipeNavigationController class]]) {
        return (CXSwipeNavigationController *)self.navigationController;
    } else {
        return nil;
    }
}

#pragma mark - Scroll view delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.collectionView && self.swipeNavigationController) {
        if (velocity.y > 0.0f) {
            scrollView.bounces = targetContentOffset->y < scrollView.bottomContentOffset.y || !self.swipeNavigationController.canPush;
        } else {
            scrollView.bounces = targetContentOffset->y > scrollView.topContentOffset.y || !self.swipeNavigationController.canPop;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView && self.swipeNavigationController) {
        scrollView.bounces = YES;
    }
}

@end
