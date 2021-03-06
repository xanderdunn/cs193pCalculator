//
//  CalculatorModel.m
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "CalculatorModel.h"

@interface CalculatorModel()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorModel
- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.programStack];
}

- (NSMutableArray *)programStack { // lazy instantiation
    if(!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)pushOntoStack:(id)object { // add to programStack
    if ([object isKindOfClass:[NSString class]] ||
        [object isKindOfClass:[NSNumber class]]) { // prevent illegal types
        [self.programStack addObject:object];
    }
}

-(void)clearStack { // empty stack
    [self.programStack removeAllObjects];
}

- (id)program { // program is immutable copy of programStack
    return [self.programStack copy];
}

#define TWO_OPERAND_OPERATIONS @[@"+", @"*", @"-", @"/"]
#define ONE_OPERAND_OPERATIONS @[@"sin", @"cos", @"sqrt", @"log"]

// FIXME: Break this monolithic function into small functions.  Reduce duplication
// Process all values in a program, turning it into an array of one single
//
+ (NSMutableArray *)formattedProgram:(NSMutableArray *)program {
    NSMutableArray *result = program;
    
    id operandA;
    id operandB;
    id operation;
    int i = 0;
    
    // FIXME: This recursive implementation is messy.
    
    for (i = 0; i < [program count]; i++) {
        operation = [program objectAtIndex:i];
        
        // two operand situation
        if ([TWO_OPERAND_OPERATIONS containsObject:operation]) {
            if ((i - 1) < 0) { // Both operands are not in the stack
                operandA = @"nan";
                operandB = @"nan";
            } else if ((i - 2) < 0) { // One operand is not in the stack
                operandA = [program objectAtIndex:(i - 1)];
                [program removeObjectAtIndex:(i - 1)];
                i = i - 1; // correct insert position
                operandB = @"nan";
            } else { // Both operands are in the stack
                operandA = [program objectAtIndex:(i - 1)];
                [program removeObjectAtIndex:(i - 1)];
                operandB = [program objectAtIndex:(i - 2)];
                [program removeObjectAtIndex:(i - 2)];
                i = i - 2; // correct insert position
            }
            // Convert NSNumber's to NSString
            operandA = [NSString stringWithFormat: @"%@", operandA];
            operandB = [NSString stringWithFormat:@"%@", operandB];
            
            NSString *formattedString;
            
            // FIXME: Rather than checking to see if operandA or operandB
            //  contains a + or - anywhere, check to see that the first
            //  operation contained in the string is a + or -
            
            // Parenthesis around + or - operations in operandA
            if ([operandA rangeOfString:@"+"].length ||
                [operandA rangeOfString:@"-"].length) {
                formattedString = [NSString stringWithFormat:@"%@ %@ (%@)",
                                   operandB, operation, operandA];
            }
            // Parenthesis around + or - operations in operandB
            else if ([operandB rangeOfString:@"+"].length ||
                     [operandB rangeOfString:@"-"].length) {
                formattedString = [NSString stringWithFormat:@"(%@) %@ %@",
                                   operandB, operation, operandA];
                
            } else formattedString = [NSString stringWithFormat:@"%@ %@ %@",
                                      operandB, operation, operandA];
            
            [program replaceObjectAtIndex:i withObject:formattedString];
            result = [CalculatorModel formattedProgram:program];
        }
        // One operand situation
        else if ([ONE_OPERAND_OPERATIONS containsObject:operation]) {
            if ((i - 1) < 0) { // Operand is not in the stack
                operandA = @"0"; // Default to operand of 0
            } else { // operand is in the stack
                operandA = [program objectAtIndex:(i - 1)];
                [program removeObjectAtIndex:(i - 1)];
                i = i - 1; // correct insert position
            }
            // Convert to string
            operandA = [NSString stringWithFormat: @"%@", operandA];
            NSString *formattedString = [NSString stringWithFormat:
                                         @"%@(%@)", operation, operandA];
            [program replaceObjectAtIndex:i withObject:formattedString];
            result = [CalculatorModel formattedProgram:program];
        }
        
        // evaluate sign changes
        else if ([operation isEqualToString:@"+/-"]) {
            if ((i - 1) < 0) { // Operand is not in the stack
                operandA = @"0"; // Default to operand of 0
            } else { // operand is in the stack
                operandA = [program objectAtIndex:(i - 1)];
                [program removeObjectAtIndex:(i - 1)];
                i = i - 1; // correct insert position
                operandA = [NSString stringWithFormat:@"%@", operandA];
                if ([operandA characterAtIndex:0] == '-') {
                    operandA = [operandA substringFromIndex:1];
                } else { // add minus to the string
                    operandA = [@"-" stringByAppendingString:operandA];
                }
            }
            [program replaceObjectAtIndex:i withObject:operandA];
            result = [CalculatorModel formattedProgram:program];
        }
    }
    return result;
    
}

// FIXME: Evaluate "+/-" operations in the description so that they
//  appear as negative numbers rather than as operations: +/-(num)
// Format an intelligent string describing the math operations
+ (NSString *)descriptionOfProgram:(id)program {
    
    NSString *result = @""; // Needs to be initialized for later appending
    
    NSMutableArray *formatedProgram = [CalculatorModel formattedProgram:
                                       [program mutableCopy]];
    NSUInteger count = [formatedProgram count];
    for (int i = count - 1; i > 0; i--) { // comma-separated NSString
        result = [result stringByAppendingFormat:@"%@, ",
                  [formatedProgram objectAtIndex:i]];
    }
    // No comma for the last object
    if ([formatedProgram count]) {
        return [result stringByAppendingFormat:@"%@", [formatedProgram
                                                       objectAtIndex:0]];
    } else return @"";
}

// Recursively evaluate an operand stack
+ (double)popOperandOffStack:(NSMutableArray *)stack {
    double result = NAN;
    
    if (![stack count]) { // stack is empty
        return 0;
    }
    
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
            else result = NAN;
        }
        // TODO: Also put in the NAN conditions for sin and cos
        else if ([topOfStack isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([topOfStack isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([topOfStack isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffStack:stack];
            if (operand >= 0) result = sqrt(operand);
            else result = NAN;
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

- (void)removeLastItem {
    if ([self.program count] <= 1) {
        [self.programStack removeAllObjects];
    } else [self.programStack removeLastObject];
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
// Variables names are NSDictionary keys and variable values are objects
+ (NSNumber *)runProgram:(id)program
     usingVariableValues:(NSDictionary *)variableValues {
    NSSet* usedVariables = [CalculatorModel variablesUsedInProgram:program];
    NSMutableArray *mutableProgram;
    
    if ([program count] == 0) return [NSNumber numberWithFloat:NAN];
    
    // replace variables with values
    if ([program isKindOfClass:[NSArray class]]) { // NSArray?
        mutableProgram = [program mutableCopy];
        for (int i = 0; i < [mutableProgram count]; i++) { // Enumerate elements
            id obj = [program objectAtIndex:i];
            if ([obj isKindOfClass:[NSString class]]) { // NSString?
                if ([usedVariables containsObject:obj]) { // variable?
                    if ([variableValues objectForKey:obj]) { // defined var?
                        [mutableProgram replaceObjectAtIndex:i withObject:
                         [variableValues objectForKey:obj]];
                    }
                }
            }
        }
    }
    
    double result = [self runProgram:[mutableProgram copy]];
    return [NSNumber numberWithDouble:result];
}

@end
