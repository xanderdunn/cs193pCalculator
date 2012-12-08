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

- (void)setScale:(CGFloat)scale { // scale change requires redraw
    if (scale != _scale) { // setNeedsDisplay is expensive, check for change
        _scale = scale;
        [self setNeedsDisplay]; // If scale changed, update display
    }
}

- (void)setOrigin:(CGPoint)origin { // origin change requires redraw
    if (origin.x != _origin.x || origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay]; // If scale changed, update display
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Take a y-value in the coordinate system of the model and convert to the
//  View's coordinate system
- (CGFloat)convertYValue:(CGFloat)yValue {
    if (self.origin.y > 0) return self.origin.y - (yValue * self.scale);
    else return (yValue * self.scale) + self.origin.y;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // default origin
    self.origin = CGPointMake(rect.size.width/2, rect.size.height/2);
    self.scale = 50; // default scale
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    // Convert View Coordinates --> Axes Coordinates
    self.xMaximum = (rect.size.width - self.origin.x)/self.scale;
    self.xMinimum = self.xMaximum - (rect.size.width/self.scale);
    self.increment = fabs(self.xMaximum-self.xMinimum)/rect.size.width;
    self.yMaximum = self.origin.y/self.scale;
    self.yMinimum = self.yMaximum - (rect.size.height/self.scale);
    
    // Get data points
    NSArray *points = [self.dataSource pointsForGraphView:self];
    
    CGFloat xValue = 0;
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    CGContextMoveToPoint(context, xValue,
                         [self convertYValue:
                          [[points objectAtIndex:0] floatValue]]);
    
    // FIXME: Use pixels rather than points for the x values/increment
    for (int i = 1; i < [points count]; i++) {
        xValue++; // move forward
        CGFloat yValue = [[points objectAtIndex:i] floatValue];
        UIGraphicsPushContext(context);
        CGContextAddLineToPoint(context, xValue, [self convertYValue:yValue]);
        UIGraphicsPopContext();
    }
    CGContextStrokePath(context);
    
    NSLog(@"self.contentScalingFactor = %f", self.contentScaleFactor);
    
}

@end
