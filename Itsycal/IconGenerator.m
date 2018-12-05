//
//  IconGenerator.m
//  Itsycal
//
//  Created by Brad Howes on 12/5/18.
//  Copyright © 2018 mowglii.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "IconGenerator.h"

static CGImageRef makeAlphaMask(NSRect rect, NSString* text, NSRect textRect) {
    
    // Based on cocoawithlove.com/2009/09/creating-alpha-masks-from-text-on.html
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef maskContext = CGBitmapContextCreate(nil, rect.size.width, rect.size.height, 8, rect.size.width, colorSpace, 0);
    CGContextSetShouldSmoothFonts(maskContext, false);
    
    CGColorSpaceRelease(colorSpace);
    
    NSGraphicsContext* maskGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:maskContext flipped:NO];
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:maskGraphicsContext];
    
    [[NSColor whiteColor] set];
    CGContextFillRect(maskContext, rect);
    
    NSMutableParagraphStyle *pstyle = [NSMutableParagraphStyle new];
    pstyle.alignment = NSTextAlignmentCenter;
    
    [text drawInRect:textRect
      withAttributes: @{NSFontAttributeName: [NSFont systemFontOfSize: 12.0 weight: NSFontWeightSemibold],
                        NSParagraphStyleAttributeName: pstyle,
                        NSForegroundColorAttributeName: [NSColor blackColor]}];
    
    [NSGraphicsContext restoreGraphicsState];
    CGImageRef alphaMask = CGBitmapContextCreateImage(maskContext);
    
    return alphaMask;
}

static BOOL drawIcon(IconKind kind, NSRect rect, NSString* text) {
    CGContextRef const context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetShouldSmoothFonts(context, false);
    
    NSRect insetRect = NSInsetRect(rect, 3.5, 0.5);
    NSRect textRect = NSOffsetRect(rect, 0, -3);
    
    switch(kind) {
        case IconKindFancyOutline: {
            [[NSColor whiteColor] set];
            [[NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:3 yRadius:3] stroke];
            
            
            // Draw text.
            NSMutableParagraphStyle *pstyle = [NSMutableParagraphStyle new];
            pstyle.alignment = NSTextAlignmentCenter;
            [text drawInRect: textRect
              withAttributes: @{NSFontAttributeName: [NSFont systemFontOfSize:12.0 weight:NSFontWeightSemibold],
                                NSForegroundColorAttributeName: [NSColor whiteColor],
                                NSParagraphStyleAttributeName: pstyle}];
        }
            break;
            
        case IconKindFancyFilled: {
            CGContextSaveGState(context);
            CGContextClipToRect(context, rect);
            CGContextClipToMask(context, rect, makeAlphaMask(rect, text, textRect));
            [[NSColor whiteColor] set];
            [[NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:3 yRadius:3] fill];
            CGContextRestoreGState(context);
        }
            break;
            
        case IconKindBasicOutline: {
            // Draw outlined icon image.
            [[NSColor blackColor] set];
            [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(rect, 3.5, 0.5) xRadius:2 yRadius:2] stroke];
            
            // Turning off smoothing looks better (why??).
            CGContextSetShouldSmoothFonts(context, false);
            
            // Draw text.
            NSMutableParagraphStyle *pstyle = [NSMutableParagraphStyle new];
            pstyle.alignment = NSTextAlignmentCenter;
            [text drawInRect:NSOffsetRect(rect, 0, -1) withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:11.5 weight:NSFontWeightSemibold], NSParagraphStyleAttributeName: pstyle, NSForegroundColorAttributeName: [NSColor blackColor]}];
        }
            break;
            
        case IconKindBasicFilled: {
            
            // Draw solid background icon image.
            // Based on cocoawithlove.com/2009/09/creating-alpha-masks-from-text-on.html
            
            // Make scale adjustments.
            NSRect deviceRect = CGContextConvertRectToDeviceSpace(context, rect);
            CGFloat scale  = NSHeight(deviceRect)/NSHeight(rect);
            CGFloat width  = scale * NSWidth(rect);
            CGFloat height = scale * NSHeight(rect);
            CGFloat outsideMargin = scale * 3;
            CGFloat radius = scale * 2;
            CGFloat fontSize = scale > 1 ? 24 : 11.5;
            
            // Create a grayscale context for the mask
            CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
            CGContextRef maskContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorspace, 0);
            CGColorSpaceRelease(colorspace);
            
            // Switch to the context for drawing.
            // Drawing done in this context is scaled.
            NSGraphicsContext *maskGraphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:maskContext flipped:NO];
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:maskGraphicsContext];
            
            // Draw a white rounded rect background into the mask context
            [[NSColor whiteColor] setFill];
            [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(deviceRect, outsideMargin, 0) xRadius:radius yRadius:radius] fill];
            
            // Draw text.
            NSMutableParagraphStyle *pstyle = [NSMutableParagraphStyle new];
            pstyle.alignment = NSTextAlignmentCenter;
            [text drawInRect:NSOffsetRect(deviceRect, 0, -1) withAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:fontSize weight:NSFontWeightBold], NSForegroundColorAttributeName: [NSColor blackColor], NSParagraphStyleAttributeName: pstyle}];
            
            // Switch back to the image's context.
            [NSGraphicsContext restoreGraphicsState];
            CGContextRelease(maskContext);
            
            // Create an image mask from our mask context.
            CGImageRef alphaMask = CGBitmapContextCreateImage(maskContext);
            
            // Fill the image, clipped by the mask.
            CGContextClipToMask(context, rect, alphaMask);
            [[NSColor blackColor] set];
            NSRectFill(rect);
            
            CGImageRelease(alphaMask);
        }
            break;
            
        default:
            return NO;
    }
    
    if (kind == IconKindFancyOutline || kind == IconKindFancyFilled) {
        NSRect redBar = rect;
        redBar.origin.y = redBar.size.height - 5;
        redBar.size.height = 5;
        [[NSColor redColor] set];
        
        NSBezierPath* path = [NSBezierPath bezierPathWithRect:NSInsetRect(redBar, 3.5, 0.0)];
        [path fill];
    }
    
    return YES;
}

NSImage* makeIcon(IconKind kind, NSString* text)
{
    // Measure text width
    NSFont *font = [NSFont systemFontOfSize:12.0 weight:NSFontWeightBold];
    CGRect textRect = [[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}] boundingRectWithSize:CGSizeMake(999, 999) options:0 context:nil];
    
    // Icon width is at least 23 pts with 3 pt outside margins, 4 pt inside margins.
    CGFloat width = MAX(3 + 4 + ceilf(NSWidth(textRect)) + 4 + 3, 23);
    CGFloat height = (kind == IconKindBasicOutline || kind == IconKindBasicFilled) ? 16 : 20;

    NSImage * image = [NSImage imageWithSize:NSMakeSize(width, height) flipped:NO drawingHandler:^BOOL (NSRect rect) {
        // NOTE: this must be self-contained as it can be executed at any time.
        return drawIcon(kind, rect, text);
    }];
    
    [image setTemplate:(kind == IconKindBasicOutline || kind == IconKindBasicFilled)];
    
    return image;
}
