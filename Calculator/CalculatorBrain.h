//
//  CalculatorBrain.h
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
- (void)pushOperand:(double)operand;
- (double)performOperation:(NSString *)operation;
- (void)clearStack;
- (NSString *)description;

@property (readonly) id program;

// With this class method, someone who has a program in hand doesn't even need
//  a CalculatorBrain.  It can just have the Class run it with this method.
+ (double)runProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end