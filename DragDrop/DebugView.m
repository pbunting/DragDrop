//
//  DebugView.m
//  DragAndDrop
//
//  Created by Paul Bunting on 1/3/15.
//  Copyright (c) 2015 Paul Bunting. All rights reserved.
//

#import "DebugView.h"

@implementation DebugView

- (void)drawRect:(CGRect)rect {
    // Drawing code
    for (int i = 0; i < [_linesToDraw count]; i = i + 2) {
        NSNumber* n1 = (NSNumber*)_linesToDraw[i];
        NSNumber* n2 = (NSNumber*)_linesToDraw[i + 1];
        CGPoint a = CGPointMake([n1 intValue], [n2 intValue]);
        [self drawLineFrom:_from To:a];
    }
    _linesToDraw = nil;
}

- (void) drawLineFrom:(CGPoint)source To:(CGPoint)target
{
    NSLog(@"drawLineFrom %f %f to %f %f", source.x, source.y, target.x, target.y);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //    UIGraphicsBeginImageContext(self.collectionView.frame.size);
    CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0, 1.0);
    CGContextSetLineWidth(context, 5.0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, source.x, source.y);
    CGContextAddLineToPoint(context, target.x, target.y);
    CGContextStrokePath(context);
    UIGraphicsEndImageContext();
    
}

@end
