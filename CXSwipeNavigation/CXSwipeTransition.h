//
//  CXSwipeTransition.h
//  CALX
//
//  Created by Daniel Clelland on 20/07/14.
//  Copyright (c) 2014 Daniel Clelland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXSwipeTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) UINavigationControllerOperation operation;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) CGFloat gutter;

@end
