//
//  UIView-KIFAdditions.h
//  KIF
//
//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>


@interface UIView (KIFAdditions)

@property (nonatomic, readonly, getter=isTappable) BOOL tappable;

- (BOOL)isDescendantOfFirstResponder;
- (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label;
- (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label traits:(UIAccessibilityTraits)traits;
- (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label accessibilityValue:(NSString *)value traits:(UIAccessibilityTraits)traits;
- (UIView *)viewWithClassName:(NSString *)className;

/*!
 @method accessibilityElementMatchingBlock:
 @abstract Finds the descendent accessibility element that matches the conditions defined by the match block.
 @param matchBlock A block which returns YES for matching elements.
 @result The matching accessibility element.
 */
- (UIAccessibilityElement *)accessibilityElementMatchingBlock:(BOOL(^)(UIAccessibilityElement *))matchBlock;

- (UIView *)subviewWithClassNamePrefix:(NSString *)prefix;
- (UIView *)subviewWithClassNameOrSuperClassNamePrefix:(NSString *)prefix;

- (void)flash;
- (void)tap;
- (void)tapAtPoint:(CGPoint)point;
- (void)dragFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
- (void)dragAlongPathWithPoints:(CGPoint *)points count:(NSInteger)count;

/*!
 @method isTappableWithHitTestResultView:
 @abstract Easy hook to override whether a hit test result makes a view tappable.
 @discussion Some times, your view hierarchies involve putting overlays over views that would otherwise be tappable. Since KIF doesn't know about these exceptions, you can override this method as a convenient way of hooking in to the check for something being tappable. Your implementation will probably want to call up to super.
 @param hitView The view -hitTest: returned when trying to tap on a point inside your view's bounds
 @result Whether or not the view is tappable.
 */
- (BOOL)isTappableWithHitTestResultView:(UIView *)hitView;

/*!
 @method isTappableInRect:
 @abstract Whether or not the receiver can be tapped inside the given rectangular area.
 @discussion Determines whether or not tapping within the given rectangle would actually hit the receiver or one of its children. This is useful for determining if the view is actually on screen and enabled.
 @param rect A rectangle specifying an area in the receiver in the receiver's frame coordinates.
 @result Whether or not the view is tappable.
 */
- (BOOL)isTappableInRect:(CGRect)rect;

/*!
 @method tappablePointInRect:(CGRect)rect;
 @abstract Finds a point in the receiver that is tappable.
 @discussion Finds a tappable point in the receiver, where tappable is defined as a point that, when tapped, will hit the receiver.
 @param rect A rectangle specifying an area in the receiver in the receiver's frame coordinates.
 @result A tappable point in the receivers frame coordinates.
 */
- (CGPoint)tappablePointInRect:(CGRect)rect;

@end
