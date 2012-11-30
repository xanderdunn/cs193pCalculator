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
//@property (nonatomic, strong) NSDictionary *variables;
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
            double digit = [self popOperandOffStack:stack];
            if (!digit) result = 0; // Prevent -0
            else result = -1 * digit;
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

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSOrderedSet *operations = [NSOrderedSet orderedSetWithObjects:
                                @"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt",
                                @"π", @"+/-", @"e", @"log", nil];
    
    // FIXME: Do I need to do alloc init here?
    NSSet *variables = nil;
    
    if ([program isKindOfClass:[NSArray class]]) {
        for (id obj in program) {
            if ([obj isKindOfClass:[NSString class]]) {
                if (![operations containsObject:obj]) {
                    // FIXME: Does this alloc and init?
                    variables = [variables setByAddingObject:obj];
                }
            }
        }
    }
    NSLog(@"%@", variables);
    return variables;
}

+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues {
    NSSet* usedVariables = [CalculatorBrain variablesUsedInProgram:program];
    
    int i = 0;
    
    if ([program isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableProgram = [program mutableCopy];
        for (i = 0; i < [mutableProgram count]; i++) {
            id obj = [program objectAtIndex:i];
            if ([obj isKindOfClass:[NSString class]]) {
                if ([usedVariables containsObject:obj]) {
                    // FIXME: Does this syntax correctly set the array value?
                    program[i] = [variableValues objectForKey:obj];
                }
            }
        }
    }
    return [self runProgram:program];
}

// TODO: Create an NSDictionary which functions as a dictionary for storing
//  possible operands and their corresponding
// Dictionary to store all possible operations and their corresponding methods

@end
