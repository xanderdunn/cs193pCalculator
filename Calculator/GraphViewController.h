//
//  GraphViewController.h
//  Calculator
//
//  Created by admin on 7/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController
<SplitViewBarButtonItemPresenter>
- (void)programChanged:(id)program;
@end
