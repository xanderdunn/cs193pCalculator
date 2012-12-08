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

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // default origin
    self.origin = CGPointMake(rect.size.width/2, rect.size.height/2);
    self.scale = 50; // default scale
    NSLog(@"rect.size.height = %f", rect.size.height);
    NSLog(@"rect.size.width = %f", rect.size.width);
    
    [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];
    
    // Convert View Coordinates --> Axes Coordinates
    self.xMaximum = (rect.size.width - self.origin.x)/self.scale;
    NSLog(@"xMaximum = %f", self.xMaximum);
    self.xMinimum = self.xMaximum - (rect.size.width/self.scale);
    self.increment = fabs(self.xMaximum-self.xMinimum)/rect.size.width;
    NSLog(@"xMinimum = %f", self.xMinimum);
    self.yMaximum = self.origin.y/self.scale;
    NSLog(@"yMaximum = %f", self.yMaximum);
    self.yMinimum = self.yMaximum - (rect.size.height/self.scale);
    NSLog(@"yMinimum = %f", self.yMinimum);
    
    // Get data points
    NSArray *points = [self.dataSource pointsForGraphView:self];
    NSLog(@"points = %@", points);
    
    CGFloat xValue = self.xMinimum + 1;
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blueColor] setStroke];
    // CGContextBeginPath(context);
    CGContextMoveToPoint(context, xValue, [[points objectAtIndex:0] floatValue]*
                         self.scale);
    
    // FIXME: Somewhere, convestion between view and model coordinate systems
    //  is messed up
    for (int i = 1; i < [points count]; i++) {
        CGFloat yValue = [[points objectAtIndex:i] floatValue];
        UIGraphicsPushContext(context);
        CGContextAddLineToPoint(context, xValue, yValue * self.scale);
        UIGraphicsPopContext();
        xValue++; // move forward
    }
    CGContextStrokePath(context);
    
    NSLog(@"self.contentScalingFactor = %f", self.contentScaleFactor);
    
}

@end
