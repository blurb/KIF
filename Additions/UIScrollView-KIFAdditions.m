//
//  UIScrollView-KIFAdditions.m
//  KIF
//
//  Created by Eric Firestone on 5/22/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "UIScrollView-KIFAdditions.h"
#import "LoadableCategory.h"
#import "UIApplication-KIFAdditions.h"
#import "UIView-KIFAdditions.h"


MAKE_CATEGORIES_LOADABLE(UIScrollView_KIFAdditions)


@implementation UIScrollView (KIFAdditions)

- (void)scrollViewToVisible:(UIView *)view animated:(BOOL)animated;
{
    BOOL needsUpdate = NO;
    CGRect frame = [self.window convertRect:self.frame fromView:self];
    
    CGRect viewFrame = [self.window convertRect:view.frame fromView:view.superview];
    CGFloat viewMaxX = viewFrame.origin.x + viewFrame.size.width;
    CGFloat viewMaxY = viewFrame.origin.y + viewFrame.size.height;
    CGFloat scrollViewMaxX = frame.origin.x + frame.size.width;
    CGFloat scrollViewMaxY = frame.origin.y + frame.size.height;
    
    CGPoint offsetPoint = self.contentOffset;
    if (viewMaxX > scrollViewMaxX) {
        // The view is to the right of the view port, so scroll it just into view
        offsetPoint.x = viewMaxX + frame.origin.x - frame.size.width;
        needsUpdate = YES;
    } else if (viewMaxX < 0.0) {
        offsetPoint.x = viewFrame.origin.x;
        needsUpdate = YES;
    }
    
    if (viewMaxY > scrollViewMaxY) {
        // The view is below the view port, so scroll it just into view
        offsetPoint.y = viewMaxY + frame.origin.y - frame.size.height;
        needsUpdate = YES;
    } else if (viewMaxY < 0.0) {
        offsetPoint.y = viewFrame.origin.y;
        needsUpdate = YES;
    }
    
    if (needsUpdate) {
        CGPoint oldPoint = offsetPoint;
        offsetPoint = [self.window convertPoint:offsetPoint toView:self];
        if (oldPoint.y == self.contentOffset.y) {
            offsetPoint.y = oldPoint.y;
        } if (oldPoint.x == self.contentOffset.x) {
            offsetPoint.x = oldPoint.x;
        }
        [self setContentOffset:offsetPoint animated:animated];
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.2, false);
    }
}

@end
