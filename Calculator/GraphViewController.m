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

@interface GraphViewController () <GraphViewDataSource,
UISplitViewControllerDelegate>
@property (nonatomic) GraphModel *graphModel;
@property (nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;
@property (nonatomic) IBOutlet UIToolbar *toolbar;
@end

@implementation GraphViewController
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

// Helper function for splitViewBarButonItem setter
- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) { // Remove old button if it exists
        [toolbarItems removeObject:_splitViewBarButtonItem];
    }
    if (splitViewBarButtonItem) { // Add new button if it exists
        [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    }
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

// Setter for the splitViewBarButtonItem
- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem {
    if (_splitViewBarButtonItem != splitViewBarButtonItem) {
        // Update only if the old is different from the new
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void)viewDidLoad { // Disable pop-over appearance on swipe gesture
    self.splitViewController.presentsWithGesture = NO;
}

- (void)programChanged:(id)program { // Update the graph on program change
    self.graphModel.program = program;
    self.programDisplay.text = [@"y = " stringByAppendingString:
                                [CalculatorModel
                                 descriptionOfProgram:program]];
    [self.graphView setNeedsDisplay];
}

- (GraphModel *)graphModel { // overload getter for lazy instantiation
    if (!_graphModel) _graphModel = [[GraphModel alloc] init];
    return _graphModel;
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
    // Pass data to the view
    return [self.graphModel calculatePointsWithXMinimum:sender.xMinimum
                                           withXMaximum:sender.xMaximum
                                           withYMinimum:sender.yMinimum
                                           withYMaximum:sender.yMaximum
                                          withIncrement:sender.increment];
}

@end