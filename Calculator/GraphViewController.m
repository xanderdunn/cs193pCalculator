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

@interface GraphViewController () <GraphViewDataSource>
@property (nonatomic) GraphModel *graphModel;
@property (nonatomic) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController 
// TODO: Call [graphModel - (NSArray *)calculatePointsAtOrigin:(CGPoint)axisOrigin
//  withScale:(CGFloat)pointsPerUnit]
// Pass the array of values to the View

// TODO: Pinch Gesture

// TODO: Pan gesture

// TODO: Triple-tap Gesture

@end