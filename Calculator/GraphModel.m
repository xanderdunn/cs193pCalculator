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

- (void)setProgram:(id)program {
    _program = program; // set program
    [self.delegate modelChanged]; // notify of data change
}

- (id)calculatePointsWithXMinimum:(float)xMinimum
                     withXMaximum:(float)xMaximum
                     withYMinimum:(float)yMinimum
                     withYMaximum:(float)yMaximum
                    withIncrement:(float)increment {
    
    if (![self.program containsObject:@"x"]) {
        return [CalculatorModel runProgram:self.program
                       usingVariableValues:nil];
    } else {
        NSMutableArray *points = [[NSMutableArray alloc] init];
        NSDictionary *variableValues;
        
        for (float x = xMinimum; x < xMaximum; x += increment) { // Iterate x
            variableValues = [NSDictionary dictionaryWithObject:
                              [NSNumber numberWithFloat:x] forKey:@"x"];
            
            NSNumber *yValue = [CalculatorModel runProgram:self.program
                                       usingVariableValues:variableValues];
            if ([yValue floatValue] <= yMaximum &&
                [yValue floatValue] >= yMinimum) [points addObject:yValue];
            else [points addObject:[NSNumber numberWithFloat:NAN]];
        }
        return [points copy]; // return immutable array
    }
}

@end
