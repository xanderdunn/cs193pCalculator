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
    if (self.splitViewController) {
        if (_splitViewBarButtonItem != splitViewBarButtonItem) {
            // Update only if the old is different from the new
            [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
        }
    }
}

// TODO: Also put the current program into NSUserDefaults
- (void)viewWillAppear:(BOOL)animated { // Get NSUserDefaultsValues
    [super viewWillAppear:animated];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    CGFloat x = [defaults floatForKey:@"originx"];
    CGFloat y = [defaults floatForKey:@"originy"];
    self.graphView.origin = CGPointMake(x, y);
    self.graphView.scale = [defaults floatForKey:@"scale"];
}

- (void)viewWillDisappear:(BOOL)animated { // Set NSUserDefaults
    [super viewWillDisappear:animated];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:self.graphView.origin.x forKey:@"originx"];
    [defaults setFloat:self.graphView.origin.y forKey:@"originy"];
    [defaults setFloat:self.graphView.scale forKey:@"scale"];
    // Set NSUserDefaultsValues
    
}

- (void)viewDidLoad { // Disable pop-over appearance on swipe gesture
    self.splitViewController.presentsWithGesture = NO;
    if (!self.splitViewController) { // Upadte label after IBOutlet set
        self.programDisplay.text = [@"y = " stringByAppendingString:
                                    [CalculatorModel
                                     descriptionOfProgram:
                                     self.graphModel.program]];
    }
    [super viewDidLoad];
}

- (void)programChanged:(id)program { // Update the graph on program change
    self.graphModel.program = program;
    self.programDisplay.text = [@"y = " stringByAppendingString:
                                [CalculatorModel
                                 descriptionOfProgram:program]];
    if (self.splitViewController) { // Need to update only if on iPad
        [self.graphView setNeedsDisplay];
    }
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

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end