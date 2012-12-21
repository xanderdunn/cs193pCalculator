//
//  GraphModel.h
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GraphModel;

@protocol ModelChanged
- (void)modelChanged; // called when the model's data changes
@end

@interface GraphModel : NSObject

// Iterate across all x-values to get y-values for plotting
// Return an NSNumber if the program contains no variables
// Return NSDictionary of values otherwise
- (id)calculatePointsWithXMinimum:(float)xMinimum
                            withXMaximum:(float)xMaximum
                            withYMinimum:(float)yMinimum
                            withYMaximum:(float)yMaximum
                           withIncrement:(float)increment;

@property (nonatomic) id program; // program from the calculator
// delegate where modelChanged messages are sent
@property (nonatomic, weak) id <ModelChanged> delegate;
@end