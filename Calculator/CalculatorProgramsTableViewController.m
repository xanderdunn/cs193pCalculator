//
//  CalculatorProgramsTableViewController.m
//  Calculator
//
//  Created by admin on 21/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import "CalculatorProgramsTableViewController.h"
#import "CalculatorModel.h"

@interface CalculatorProgramsTableViewController ()

@end

@implementation CalculatorProgramsTableViewController
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.programs count]; // number of programs in the array
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Calculator Program Description";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier forIndexPath:indexPath];
    
    // Get the program corresponding to the row
    id program = [self.programs objectAtIndex:indexPath.row];
    // Put the text into the table cell
    cell.textLabel.text = [@"y = " stringByAppendingString:
                           [CalculatorModel descriptionOfProgram:program]];
    return cell;
}

# define FAVORITES_KEY @"CalculatorGraphViewController.Favorites"

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:
(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Get user preferces and make the change
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY]
                                     mutableCopy];
        [favorites removeObjectAtIndex:indexPath.row];
        [defaults setObject:favorites forKey:FAVORITES_KEY];
#warning FIXME: Why does this crash?
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:
         UITableViewRowAnimationFade];
        [defaults synchronize]; // write to disk
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath
{
    id program = [self.programs objectAtIndex:indexPath.row]; // get program
    // send the signal to the delegate
    [self.delegate calculatorProgramsTableViewController:self
                                            choseProgram:program];
    if (self.navigationController) { // Return to graph screen on iPhone
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
