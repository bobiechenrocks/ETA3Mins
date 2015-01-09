//
//  ETAConfigTableViewController.h
//  ETA3Mins
//
//  Created by Bobie Chen on 1/9/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ETAConfigSelectDelegate <NSObject>

@optional
- (NSArray*)provideDefaultConfigs;
- (void)didSelectDefaultConfid:(NSDictionary*)configDict;

@end

@interface ETAConfigTableViewController : UITableViewController

@property (nonatomic, weak) id<ETAConfigSelectDelegate> delegate;

@end
