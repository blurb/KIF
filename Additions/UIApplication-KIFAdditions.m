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

#define DEFAULT_SCREENSHOT_QUALITY .8

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

    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    CGRect statusBarFrame = [self statusBarFrame];
    NSInteger statusBarHeight = self.statusBarHidden ? 0 : statusBarFrame.size.height;

    imageSize.height -= statusBarHeight;
    
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    

    for (UIWindow *window in windows) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            
            
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y - statusBarHeight);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context); 

        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSString *outputFormat = [[[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCREENSHOT_FORMAT"] lowercaseString];

    // validate that outputFormat is png or jpg
    if (!outputFormat || ([outputFormat rangeOfString:@"png|jpg" options:NSRegularExpressionSearch].location == NSNotFound))
        outputFormat = @"png";
        
    outputPath = [outputPath stringByExpandingTildeInPath];
    outputPath = [outputPath stringByAppendingPathComponent:[name stringByReplacingOccurrencesOfString:@"/" withString:@"_"]];
    outputPath = [outputPath stringByAppendingPathExtension:outputFormat];
    
    NSData* rawData = nil;
    if ([outputFormat isEqualToString:@"jpg"]) {
        NSString* screenshotQuality = [[[NSProcessInfo processInfo] environment] objectForKey:@"KIF_SCREENSHOT_QUALITY"];
        CGFloat quality = screenshotQuality ? [screenshotQuality floatValue] : DEFAULT_SCREENSHOT_QUALITY;
        if (quality < 0)
            quality = 0;
        if (quality > 1)
            quality = 1;
        rawData = UIImageJPEGRepresentation(image, quality);
    } else {
        rawData = UIImagePNGRepresentation(image);
    }
    
    BOOL success = [rawData writeToFile:outputPath atomically:YES];
    if (!success) {
        if (error) {
            *error = [[[NSError alloc] initWithDomain:@"KIFTest" code:KIFTestStepResultFailure userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Failed to write screenshot \"%@\" to output path \"%@\".", name,outputPath], NSLocalizedDescriptionKey, nil]] autorelease];
        }
    }
    return success;
}

@end
