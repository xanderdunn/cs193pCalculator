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
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint origin;
@end

@implementation GraphView

@synthesize scale = _scale;

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

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // default origin
    self.origin = CGPointMake(rect.size.width/2,
                                                rect.size.height/2);
    //self.scale = 50; // default scale
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    // NSDictinoary if program is a curve, NSNumber if program contains no
    //  variables
    id data = [self askForDataUsingRect:rect];
    
    CGFloat xValue = 0;
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    UIGraphicsPushContext(context);

    if ([data isKindOfClass:[NSArray class]]) { // it is a curve
        CGContextMoveToPoint(context, xValue,
                             [self convertYValue:
                              [[data objectAtIndex:0] floatValue]]);
        for (int i = 1; i < [data count]; i++) { // plot all points in array
            xValue+=1/self.contentScaleFactor; // move forward by pixel
            CGFloat yValue = [[data objectAtIndex:i] floatValue];
            CGContextAddLineToPoint(context, xValue, [self convertYValue:yValue]);
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

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale;
        gesture.scale = 1; // reset the gesture to 1
    }
}

@end
