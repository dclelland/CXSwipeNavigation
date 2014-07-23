//
//  CXSwipeTableViewController.m
//  CALX
//
//  Created by Daniel Clelland on 23/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <UIScrollView-Actions/UIScrollView+Actions.h>

#import "CXSwipeTableViewController.h"
#import "CXSwipeNavigationController.h"

@interface CXSwipeTableViewController ()

- (CXSwipeNavigationController *)swipeNavigationController;

@end

@implementation CXSwipeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.alwaysBounceVertical = YES;
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
    if (scrollView == self.tableView && self.swipeNavigationController) {
        if (velocity.y > 0.0f) {
            scrollView.bounces = targetContentOffset->y < scrollView.bottomContentOffset.y || !self.swipeNavigationController.canPush;
        } else {
            scrollView.bounces = targetContentOffset->y > scrollView.topContentOffset.y || !self.swipeNavigationController.canPop;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && self.swipeNavigationController) {
        scrollView.bounces = YES;
    }
}

@end
