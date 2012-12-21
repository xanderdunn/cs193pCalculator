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
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController () <GraphViewDataSource,
UISplitViewControllerDelegate, CalculatorProgramsTableViewControllerDelegate,
ModelChanged>
@property (nonatomic) GraphModel *graphModel;
@property (nonatomic) IBOutlet GraphView *graphView;
@property (nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation GraphViewController
@synthesize popoverController; // Prevent using instance variable

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)modelChanged {
    NSString *newTitle = [CalculatorModel descriptionOfProgram:
                          self.graphModel.program];
    if (self.splitViewController) { // Update iPad title
        UIBarButtonItem *titleButton;
        // find the title button
        for (UIBarButtonItem *button in self.toolbar.items) {
            if (button.tag == 1) { // Get the one with the right tag
                titleButton = button;
                break;
            }
        }
        titleButton.title = newTitle;
    }
    if (self.navigationController) { // Update iPhone title
        self.navigationItem.title = newTitle;
    }
    [self.graphView setNeedsDisplay]; // show new graph
}

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
    [defaults synchronize]; // write to disk
}

- (void)viewDidLoad {
    // Disable pop-over appearance on swipe gesture for iPad
    self.splitViewController.presentsWithGesture = NO;
    self.graphModel.delegate = self; // I am the graphModel's delegate
    [self modelChanged]; // update screen
    [super viewDidLoad];
}

- (void)programChanged:(id)program { // Update the graph on program change
    self.graphModel.program = program; // set new program
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

- (BOOL)shouldAutorotate { // rotate
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations { // rotate to all orientations
    return UIInterfaceOrientationMaskAll;
}

// Name of the key for the
# define FAVORITES_KEY @"CalculatorGraphViewController.Favorites"

- (IBAction)addToFavorites:(id)sender { // add program to array in user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY]
                                 mutableCopy];
    if (!favorites) favorites = [NSMutableArray array]; // create if first call
    if (![favorites containsObject:self.graphModel.program]) { // unique element
        [favorites addObject:self.graphModel.program]; // add current program
        [defaults setObject:favorites forKey:FAVORITES_KEY]; // add to dictionary
        [defaults synchronize]; // write to disk
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Favorites"]) {
        // prevent multiple popovers
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue =
            (UIStoryboardPopoverSegue *)segue;
            [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController = popoverSegue.popoverController;
        }
        
        // set-up destination view controller
        NSArray *programs = [[NSUserDefaults standardUserDefaults]
                             objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self]; // I am the delegate
    }
}

- (void)calculatorProgramsTableViewController:
(CalculatorProgramsTableViewController *)sender choseProgram:(id)program {
    self.graphModel.program = program; // model's program set to favorite
    // Remove popover after selection
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil; // Remove from memory
}

- (void)calculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender deleteProgram:(id)program
                                      atIndex:(NSInteger)index {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY]
                                 mutableCopy];
    [favorites removeObjectAtIndex:index];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    sender.programs = favorites; // set new programs array
    [defaults synchronize];
}

@end