//
//  GraphModel.h
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphModel : NSObject

- (NSArray *)calculatePointsAtOrigin:(CGPoint)axisOrigin
                                withScale:(CGFloat)pointsPerUnit;

@property (nonatomic) id program;

@end