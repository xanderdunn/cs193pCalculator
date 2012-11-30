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
    if(!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)pushOperand:(id)operand {
    [self.programStack addObject:operand];
}

// Get an empty stack
-(void)clearStack {
    [self.programStack removeAllObjects];
}

// FIXME: Is there any way to get the dictionary of variables without
- (double)performOperation:(NSString *)operation
            usingVariables:(NSDictionary *)variableValues {
    
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program usingVariableValues:variableValues];
}

// Make an immutable copy of the stack so that it can be consumed
- (id)program {
    return [self.programStack copy];
    
}

// Format an intelligent string describing the math operations
+ (NSString *)descriptionOfProgram:(id)program {
    
    if ([program isKindOfClass:[NSArray class]]) { // NSArray?
        // recursively consume the array
    }
    
    // TODO: Return an intelligent description
    // Iterate through elements of the array
    // If NSString, print.
    // If NSNumber, convert and print.
    return @"";
}

// Recursively evaluate an operand stack
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

// Evaluates a program without variables
+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

// Produces an NSSet of NSString's which are the variables used in the program
+ (NSSet *)variablesUsedInProgram:(id)program {
    NSOrderedSet *operations = [NSOrderedSet orderedSetWithObjects:
                                @"+", @"*", @"-", @"/", @"sin", @"cos", @"sqrt",
                                @"π", @"+/-", @"e", @"log", nil];
    
    NSSet *variables = [[NSSet alloc] init];
    
    if ([program isKindOfClass:[NSArray class]]) {
        for (id obj in program) {
            if ([obj isKindOfClass:[NSString class]]) {
                if (![operations containsObject:obj]) {
                    variables = [variables setByAddingObject:obj];
                }
            }
        }
    }
    return variables;
}

// Evaluates a program by substituting variable values and then calling
//  runProgram
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues {
    NSSet* usedVariables = [CalculatorBrain variablesUsedInProgram:program];
    NSLog(@"The program is: %@", program);
    NSMutableArray *mutableProgram = nil;
    
    int i = 0;
    
    if ([program isKindOfClass:[NSArray class]]) { // NSArray?
        mutableProgram = [program mutableCopy];
        for (i = 0; i < [mutableProgram count]; i++) { // Enumerate elements
            id obj = [program objectAtIndex:i];
            if ([obj isKindOfClass:[NSString class]]) { // NSString?
                if ([usedVariables containsObject:obj]) { // variable?
                    if ([variableValues objectForKey:obj]) { // defined var?
                        [mutableProgram replaceObjectAtIndex:i withObject:[variableValues objectForKey:obj]];
                    }
                }
            }
        }
    }
    return [self runProgram:[mutableProgram copy]];
}

@end
