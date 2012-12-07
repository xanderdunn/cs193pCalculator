//
//  GraphModel.m
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "GraphModel.h"
#import "CalculatorModel.h" // Need to call a +CalculatorModel class method

@implementation GraphModel

// Iterate across all x-values to get y-values for plotting
- (NSArray *)calculatePointsAtOrigin:(CGPoint)axisOrigin
                           withScale:(CGFloat)pointsPerUnit {
    NSMutableArray *points;
    NSDictionary *xValue;
    int endVal = 0; // TODO: Calculate this based on axisOrigin and
    //  pointsPerUnit
    // TODO: Convert View System --> Coordinate System
    
    // TODO
    for (int x = 0; x < endVal; x++) { // Iterate over all x
        xValue = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:x]
                                             forKey:@"x"];
        NSNumber *point = [CalculatorModel runProgram:self.program
                                  usingVariableValues:xValue];
        [points addObject:point];
    }
    return [points copy]; // return immutable copy
}

@end
