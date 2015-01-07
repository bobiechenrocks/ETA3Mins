//
//  ETALocationMapViewController.m
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ETALocationMapViewController.h"

@interface ETALocationMapViewController ()

@end

@implementation ETALocationMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Select Location";
    
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnDoneClicked)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
}

#pragma mark - button functions
- (void)btnCancelClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnDoneClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        /* pass selected location via delegate */
    }];
}

@end
