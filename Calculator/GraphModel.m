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
- (NSArray *)calculatePointsWithXMinimum:(float)xMinimum
                            withXMaximum:(float)xMaximum
                            withYMinimum:(float)yMinimum
                            withYMaximum:(float)yMaximum
                         withTotalPoints:(int)total {
    
    NSMutableArray *points = [[NSMutableArray alloc] init]; // must alloc init
    NSDictionary *variableValues;
    float increment = fabs(xMaximum - xMinimum)/total;
    
    // TODO
    for (float x = xMinimum; x < xMaximum; x += increment) { // Iterate all x
        variableValues = [NSDictionary dictionaryWithObject:
                          [NSNumber numberWithFloat:x] forKey:@"x"];
        
        NSLog(@"variableValues = %@", variableValues);
        
        NSNumber *yValue = [CalculatorModel runProgram:self.program
                                   usingVariableValues:variableValues];
        NSLog(@"yValue = %@", yValue);
        if ([yValue floatValue] <= yMaximum && [yValue floatValue] >= yMinimum)
        { // Do not add the point if it is outside the visible viewing area
            [points addObject:yValue];
        }
    }
    NSLog(@"points count = %u", [points count]);
    NSLog(@"expected total = %i", total);
    return [points copy]; // return immutable copy
}

@end
