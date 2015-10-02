//
//  ETATrackingViewController.h
//  ETA3Mins
//
//  Created by Bobie Chen on 1/7/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ETATrackingViewDelegate;

@interface ETATrackingViewController : UIViewController

@property (nonatomic, weak) id<ETATrackingViewDelegate>delegate;
@property (nonatomic, assign) BOOL bFireImmediately;

@end


@protocol ETATrackingViewDelegate <NSObject>

@required
- (NSDictionary*)provideTrackingTaskInfo;

@end
