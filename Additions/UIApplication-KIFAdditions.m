//
//  UIApplication-KIFAdditions.m
//  KIF
//
//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "UIApplication-KIFAdditions.h"
#import "LoadableCategory.h"
#import "UIView-KIFAdditions.h"
#import "KIFTestStep.h"
#import <QuartzCore/QuartzCore.h>

MAKE_CATEGORIES_LOADABLE(UIApplication_KIFAdditions)


@implementation UIApplication (KIFAdditions)

- (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label;
{
    return [self accessibilityElementWithLabel:label traits:UIAccessibilityTraitNone];
}

- (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label traits:(UIAccessibilityTraits)traits;
{
    return [self accessibilityElementWithLabel:label accessibilityValue:nil traits:traits];
}

- (UIAccessibilityElement *)accessibilityElementWithLabel:(NSString *)label accessibilityValue:(NSString *)value traits:(UIAccessibilityTraits)traits;
{
    // Go through the array of windows in reverse order to process the frontmost window first.
    // When several elements with the same accessibilitylabel are present the one in front will be picked.
    for (UIWindow *window in [[self windows] reverseObjectEnumerator]) {
        UIAccessibilityElement *element = [window accessibilityElementWithLabel:label accessibilityValue:value traits:traits];
        if (element) {
            return element;
        }
    }
    
    return nil;
}

- (UIView *)viewWithClassName:(NSString *)className;
{
    for (UIWindow *window in [self windows]) {
        UIView * view = [window viewWithClassName:className];
        if (view) {
            return view;
        }
    }
    
    return nil;
}

- (UIAccessibilityElement *)accessibilityElementMatchingBlock:(BOOL(^)(UIAccessibilityElement *))matchBlock;
{
    for (UIWindow *window in [self windows]) {
        UIAccessibilityElement *element = [window accessibilityElementMatchingBlock:matchBlock];
        if (element) {
            return element;
        }
    }
    
    return nil;
}

- (UIWindow *)keyboardWindow;
{
    for (UIWindow *window in [self windows]) {
        if ([NSStringFromClass([window class]) isEqual:@"UITextEffectsWindow"]) {
            return window;
        }
    }
    
    return nil;
}

- (UIWindow *)pickerViewWindow;
{
    for (UIWindow *window in [self windows]) {
        UIView *pickerView = [window subviewWithClassNameOrSuperClassNamePrefix:@"UIPickerView"];
        if (pickerView) {
            return window;
        }
    }
    
    return nil;
}

- (BOOL)captureScreenshotWithName:(NSString*)name error:(NSError**)error
{
    NSString *outputPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCREENSHOTS"];
    if (!outputPath) {
        if (error) {
            *error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to capture screenshot \"%@\"; no output path set", name], NSLocalizedDescriptionKey, nil]] autorelease];
        }
        return FALSE;
    }

    NSArray *windows = [self windows];
    if (windows.count == 0) {
        if (error) {
            *error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to capture screenshot \"%@\"; no windows found.", name], NSLocalizedDescriptionKey, nil]] autorelease];
        }
        return FALSE;
    }

    UIGraphicsBeginImageContext([[windows objectAtIndex:0] bounds].size);
    for (UIWindow *window in windows) {
        [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    outputPath = [outputPath stringByExpandingTildeInPath];
    outputPath = [outputPath stringByAppendingPathComponent:[name stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    outputPath = [outputPath stringByAppendingPathExtension:@"png"];
    BOOL success = [UIImagePNGRepresentation(image) writeToFile:outputPath atomically:YES];
    if (!success) {
        if (error) {
            *error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to write screenshot \"%@\" to output path \"%@\".", name,outputPath], NSLocalizedDescriptionKey, nil]] autorelease];
        }
    }
    return success;
}

@end
