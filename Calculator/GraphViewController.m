//
//  GraphViewController.m
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphModel.h"  // GraphViewController's model
#import "GraphView.h"   // GraphViewController's view
#import "CalculatorModel.h" // Need a CalculatorModel class method

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic) GraphModel *graphModel;
@property (nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;
@end

@implementation GraphViewController

- (GraphModel *)graphModel { // overload getter for lazy instantiation
    if (!_graphModel) _graphModel = [[GraphModel alloc] init];
    return _graphModel;
}

- (void)setProgramDisplay:(UILabel *)programDisplay {
    _programDisplay = programDisplay;
    
    // It should always have the value of the program's description
    self.programDisplay.text = [CalculatorModel
                                descriptionOfProgram:self.program];
}

- (void)setGraphView:(GraphView *)graphView {
    NSLog(@"I am setting the graph view now");
    _graphView = graphView;
    self.graphView.dataSource = self; // GraphViewController is the dataSource
}

- (NSArray *)pointsForGraphView:(GraphView *)sender {
    self.graphModel.program = self.program; // Update model's program
    NSLog(@"sender.xMinimum = %f", sender.xMinimum);
    
    // Pass data to the view
    return [self.graphModel calculatePointsWithXMinimum:sender.xMinimum
                                           withXMaximum:sender.xMaximum
                                           withYMinimum:sender.yMinimum
                                           withYMaximum:sender.yMaximum
                                        withTotalPoints:
            sender.totalHorizontalPoints];
}

// TODO: Pinch Gesture, adjust scale

// TODO: Pan gesture, move axes

// TODO: Triple-tap Gesture, move origin to the triple-tap

@end