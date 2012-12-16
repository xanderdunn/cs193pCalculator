//
//  SplitViewBarButtonItemPresenter.h
//  Psychologist
//
//  Created by admin on 15/D/12.
//  Copyright (c) 2012 ThoughtAdvances. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SplitViewBarButtonItemPresenter <NSObject>
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
// The user must also override the setter to put the barButtonItem in the
//      toolbar
- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem;
@end