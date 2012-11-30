//
//  CalculatorBrain.m
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain
- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.programStack];
}

- (NSMutableArray *)programStack { // lazy instantiation
    if(!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand {
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

// We don't want to remove items from the array in the programmable calculator.
//- (double)popOperand {
//    NSNumber *operandObject = [self.operandStack lastObject];
//    if (operandObject) [self.operandStack removeLastObject];
//    return [operandObject doubleValue];
//}

-(void)clearStack {
    [self.programStack removeAllObjects];
}

- (double)performOperation:(NSString *)operation{
    
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program {
    return [self.programStack copy];
    
}

+ (NSString *)descriptionOfProgram:(id)program {
    // TODO: Return an intelligent description
    // Iterate through elements of the array
    // If NSString, print.
    // If NSNumber, convert and print.
    return @"";
}

+ (double)popOperandOffStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        if([topOfStack isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] +
                     [self popOperandOffStack:stack];
        } else if ([topOfStack isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] *
                     [self  popOperandOffStack:stack];
        } else if ([topOfStack isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([topOfStack isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        } else if ([topOfStack isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([topOfStack isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([topOfStack isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffStack:stack]);
        } else if ([topOfStack isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([topOfStack isEqualToString:@"+/-"]) {
            result = -1 * [self popOperandOffStack:stack];
        } else if ([topOfStack isEqualToString:@"e"]) {
            result = M_E;
        } else if ([topOfStack isEqualToString:@"log"]) {
            result = log([self popOperandOffStack:stack]);
        }
    }
    return result;
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}
    double result = 0;

@end
