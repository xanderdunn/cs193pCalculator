//
//  GraphView.m
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@interface GraphView ()
@end

@implementation GraphView

@synthesize scale = _scale;
@synthesize origin = _origin;

- (CGFloat)scale {
    if (!_scale) return 50.0;
    else return _scale;
}

- (void)setScale:(CGFloat)scale { // scale change requires redraw
    if (scale != _scale) { // setNeedsDisplay is expensive, check for change
        _scale = scale;
        [self setNeedsDisplay]; // If scale changed, update display
    }
}

- (void)setOrigin:(CGPoint)origin { // origin change requires redraw
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay]; // If origin changed, update display
    }
}

// Take a y-value in the coordinate system of the model and convert to the
//  View's coordinate system
- (CGFloat)convertYValue:(CGFloat)yValue {
    if (self.origin.y > 0) return self.origin.y - (yValue * self.scale);
    else return (yValue * self.scale) + self.origin.y;
}

- (id)askForDataUsingRect:(CGRect)rect {
    // Convert View Coordinates --> Axes Coordinates
    self.xMaximum = (rect.size.width - self.origin.x)/self.scale;
    self.xMinimum = self.xMaximum - (rect.size.width/self.scale);
    self.increment = fabs(self.xMaximum-self.xMinimum)/rect.size.width
    /self.contentScaleFactor;
    self.yMaximum = self.origin.y/self.scale;
    self.yMinimum = self.yMaximum - (rect.size.height/self.scale);
    
    // Get data points
    return [self.dataSource pointsForGraphView:self];
}

// TODO: Improve performance of panning
//      Move what is already drawn and redrawn only what is needed?

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // default origin
    if (!self.origin.x && !self.origin.y) {
        self.origin = CGPointMake(rect.size.width/2,
                                  rect.size.height/2);
    }
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    // NSDictinoary if program is a curve, NSNumber if program contains no
    //  variables
    id data = [self askForDataUsingRect:rect];
    
    CGFloat xValue = 0;
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    UIGraphicsPushContext(context);
    
    // FIXME: Graph disappears when x-axis disappears at the top of the screen
    
    if ([data isKindOfClass:[NSArray class]] && [data count]) { // curve
//        int j = 0;
//        while ([data objectAtIndex:j] == [NSNumber numberWithFloat:NAN]) {
//            j++;
//        }
        CGContextMoveToPoint(context, xValue,
                             [self convertYValue:
                              [[data objectAtIndex:0] floatValue]]);
        for (int i = 1; i < [data count]; i++) { // plot all points in array
            xValue+=1/self.contentScaleFactor; // move forward by pixel
            NSNumber *yValue = [data objectAtIndex:i];
            CGFloat yValueFloat = [yValue floatValue];
            if (yValue == [NSNumber numberWithFloat:NAN]) {
                CGContextMoveToPoint(context, xValue,
                                     [self convertYValue:yValueFloat]);
            } else if ([data objectAtIndex:i-1] ==
                       [NSNumber numberWithFloat:NAN]) {
                // Don't use 
                CGContextMoveToPoint(context, xValue,
                                     [self convertYValue:yValueFloat]);
            } else CGContextAddLineToPoint(context, xValue,
                                           [self convertYValue:yValueFloat]);
        }
    } else if ([data isKindOfClass:[NSNumber class]]) { // constant value
        UIGraphicsPushContext(context);
        CGFloat yValue = [self convertYValue:[data floatValue]];
        CGContextMoveToPoint(context, 0.0, yValue);
        CGContextAddLineToPoint(context, rect.size.width, yValue);
    }
    CGContextStrokePath(context); // Draw the line
    UIGraphicsPopContext();
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture { // change scale on pinch
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1; // reset the gesture to 1
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture { // change origin on pan
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x/2,
                                  self.origin.y + translation.y/2);
        // We want incremental changes, so reset
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)tripleTap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationInView:self];
    }
}

@end
