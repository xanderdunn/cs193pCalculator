//
//  CalculatorModel.h
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorModel : NSObject
- (void)pushOntoStack:(id)operand;
- (void)clearStack;
- (void)removeLastItem;
- (NSString *)description;

@property (readonly) id program; // guaranteed to be a Property List

+ (double)runProgram:(id)program;
+ (NSNumber *)runProgram:(id)program
        usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;
@end