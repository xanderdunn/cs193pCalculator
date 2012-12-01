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
    if(!_programStack) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (void)pushOntoStack:(id)object { // add to programStack
    // at this point, all numbers should be converted to NSNumber
    [self.programStack addObject:object];
}

-(void)clearStack { // empty stack
    [self.programStack removeAllObjects];
}

- (id)program { // program is immutable copy of programStack
    return [self.programStack copy];
    
}

// Process all values in a program, turning it into an array of one single
//
+ (NSMutableArray *)formattedProgram:(NSMutableArray *)program {
    NSMutableArray *result = program;
    
    // FIXME: Inefficient to place these sets inside the recursive function
    // Set of operations taking two operands
    NSSet *twoOperandOperations = [NSSet setWithObjects:
                                   @"+", @"*", @"-", @"/", nil];
    
    // Set of operations taking one operand
    NSSet *oneOperandOperations = [NSSet setWithObjects:
                                   @"sin", @"cos", @"sqrt", @"+/-",
                                   @"log", nil];
    
    id operandA = nil;
    id operandB = nil;
    id operation = nil;
    int i = 0;
    
    // FIXME: This recursive implementation is messy.
    
    for (i = 0; i < [program count]; i++) {
        operation = [program objectAtIndex:i];
        if ([twoOperandOperations containsObject:operation]) {
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
            
            NSString *formattedString = nil;
            
            // FIXME: Rather than checking to see if operandA or operandB
            //  contains a + or - anywhere, check to see that the first
            //  operation contained in the string is a + or -
            
            // FIXME: Implement this using more intelligent character finding
            // If operandA contains + or -, then put () around it
            NSCharacterSet *operandAChars = [NSCharacterSet
                                             characterSetWithCharactersInString:
                                             operandA];
            
            NSCharacterSet *operandBChars = [NSCharacterSet
                                             characterSetWithCharactersInString:
                                             operandB];
            
            NSCharacterSet *plusChar = [NSCharacterSet
                                        characterSetWithCharactersInString:
                                        @"+"];
            
            NSCharacterSet *minusChar = [NSCharacterSet
                                         characterSetWithCharactersInString:
                                         @"-"];
            
            // Parenthesis around + or - operations in operandA
            if ([operandAChars isSupersetOfSet:plusChar] ||
                [operandAChars isSupersetOfSet:minusChar]) {
                formattedString = [NSString stringWithFormat:@"%@ %@ (%@)",
                                   operandB, operation, operandA];
            }
            // Parenthesis around + or - operations in operandB
            else if ([operandBChars isSupersetOfSet:plusChar] ||
                     [operandBChars isSupersetOfSet:minusChar]) {
                formattedString = [NSString stringWithFormat:@"(%@) %@ %@",
                                   operandB, operation, operandA];
                
            } else formattedString = [NSString stringWithFormat:@"%@ %@ %@",
                                      operandB, operation, operandA];
            
            [program replaceObjectAtIndex:i withObject:formattedString];
            result = [CalculatorBrain formattedProgram:program];
        } else if ([oneOperandOperations containsObject:operation]) {
            if ((i - 1) < 0) { // Operand is not in the stack
                operandA = @"0";
            } else {
                operandA = [program objectAtIndex:(i - 1)];
                [program removeObjectAtIndex:(i - 1)];
                i = i - 1; // correct insert position
            }
            operandA = [NSString stringWithFormat: @"%@", operandA];
            NSString *formattedString = [NSString stringWithFormat:
                                         @"%@(%@)", operation, operandA];
            [program replaceObjectAtIndex:i withObject:formattedString];
            result = [CalculatorBrain formattedProgram:program];
        }
    }
    return result;
    
}

// Format an intelligent string describing the math operations
+ (NSString *)descriptionOfProgram:(id)program {
    
    NSString *result = @"";
    
    NSMutableArray *formatedProgram = [CalculatorBrain formattedProgram:
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

// FIXME: Decimal numbers are not converted to NSNumber/double, but remain
//  as NSString
// FIXME: Zeros are not treated as numbers, but as nan.  Ex.: 222 E 0 +
// All double operations produce a nan

// Evaluates a program by substituting variable values and then calling
//  runProgram
+ (id)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues {
    NSSet* usedVariables = [CalculatorBrain variablesUsedInProgram:program];
    NSMutableArray *mutableProgram = nil;
    
    // replace variables with values
    if ([program isKindOfClass:[NSArray class]]) { // NSArray?
        mutableProgram = [program mutableCopy];
        for (int i = 0; i < [mutableProgram count]; i++) { // Enumerate elements
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
    
    double result = [self runProgram:[mutableProgram copy]];
    
    return [NSNumber numberWithDouble:result];
}

@end
