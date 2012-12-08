//
//  GraphModel.h
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphModel : NSObject

- (id)calculatePointsWithXMinimum:(float)xMinimum
                            withXMaximum:(float)xMaximum
                            withYMinimum:(float)yMinimum
                            withYMaximum:(float)yMaximum
                           withIncrement:(float)increment;

@property (nonatomic) id program;

@end