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

- (NSArray *)pointsForGraphView:(GraphView *)sender;

@end

@interface GraphView : UIView
@property (readonly) CGFloat scale;
@property (readonly) CGPoint origin;
@end
