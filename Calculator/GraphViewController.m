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
    self.programDisplay.text = [@"y = " stringByAppendingString:[CalculatorModel descriptionOfProgram:self.program]];
}

- (void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    // Create the gesture recognizers
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]
                                          initWithTarget:self.graphView
                                          action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc]
                                          initWithTarget:self.graphView
                                          action:
                                          @selector(pan:)]];
    UITapGestureRecognizer *tripleTap = [[UITapGestureRecognizer alloc]
                                    initWithTarget:self.graphView
                                    action:@selector(tripleTap:)];
    tripleTap.numberOfTapsRequired = 3; // Force 3 taps for recognition
    [self.graphView addGestureRecognizer:tripleTap];
    
    self.graphView.dataSource = self; // GraphViewController is the dataSource
}

- (NSArray *)pointsForGraphView:(GraphView *)sender {
    self.graphModel.program = self.program; // Update model's program
    
    // Pass data to the view
    return [self.graphModel calculatePointsWithXMinimum:sender.xMinimum
                                           withXMaximum:sender.xMaximum
                                           withYMinimum:sender.yMinimum
                                           withYMaximum:sender.yMaximum
                                          withIncrement:sender.increment];
}

@end