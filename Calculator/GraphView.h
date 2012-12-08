//
//  GraphView.h
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView; // forward reference

@protocol GraphViewDataSource // GraphViewController implements this
- (id)pointsForGraphView:(GraphView *)sender;
@end

@interface GraphView : UIView
@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;
// Values for calculating points
@property CGFloat xMaximum;
@property CGFloat xMinimum;
@property CGFloat yMinimum;
@property CGFloat yMaximum;
@property CGFloat increment;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;

@end