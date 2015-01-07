//
//  ETALocationMapViewController.m
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ETALocationMapViewController.h"
#import <MapKit/MapKit.h>

@interface ETALocationMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *map;

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation ETALocationMapViewController {
    BOOL m_bShowUserDefaultLocation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _prepareInitialLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Select Location";
    
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelClicked)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    UIBarButtonItem* doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneClicked)];
    self.navigationItem.rightBarButtonItem = doneBarButton;
}

- (void)_prepareInitialLocation {
    CLLocationCoordinate2D* location = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(provideDefaultLocation)]) {
        location = [self.delegate provideDefaultLocation];
    }
    
    m_bShowUserDefaultLocation = (location != nil);
    
    if (location) {
    }
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
