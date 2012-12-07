//
//  CalculatorBrain.h
//  Calculator
//
//  Created by admin on 27/N/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject
- (void)pushOntoStack:(id)operand;
- (void)clearStack;
- (void)removeLastItem;
- (NSString *)description;

@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (id)runProgram:(id)program
        usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end

// TO DO:
// Create a new custom subclass of GraphViewController, GraphModel, and
    // GraphView : UIView for the graph
// Get these items on the storyboard.  Link the Graph button to a segue into
    // the graphing screen
// Implement GraphModel.m =
// Implement pinching, panning, and triple-tapping
// Save scale and origin information in NSUserDefaults
// Convert to Universal App
// New storyboard for iPad, new Views.  Rewire outlets

// How do I access runProgram: usingVariables: from GraphView?
// What is contained in GraphModel?  A collection of all points that need
    // to be drawn?  Some kind of mapping between screen pixels and origin
    // and axes?

// Goals
// Handful of lines added to CalculatorViewController
// No changes to CalculatorBrain
// <100 lines of code total added