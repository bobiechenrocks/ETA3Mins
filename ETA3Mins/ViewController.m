//
//  ViewController.m
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ViewController.h"
#import "ETALocationMapViewController.h"

@interface ViewController () <ETALocationMapDelegate>

/* UI Elements*/
@property (weak, nonatomic) IBOutlet UITextField *textDestination;
@property (weak, nonatomic) IBOutlet UISlider *slideETA;
@property (weak, nonatomic) IBOutlet UILabel *textETA;
@property (weak, nonatomic) IBOutlet UITextField *textNumber;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_prepareMainView {
}

#pragma mark - button functions & IBActions
- (IBAction)onETASlided:(id)sender {
    UISlider* etaSlider = (UISlider*)sender;
    self.textETA.text = [NSString stringWithFormat:@"%lu", (NSUInteger)(etaSlider.value)];
}

- (IBAction)btnMapViewClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ETALocationMapViewController* mapVC = [storyboard instantiateViewControllerWithIdentifier:@"ETALocationMapViewController"];
    mapVC.delegate = self;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:mapVC];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction)btnStartTrackingClicked:(id)sender {
}

- (IBAction)btnSaveConfigClicked:(id)sender {
}

- (IBAction)btnLoadConfigClicked:(id)sender {
}

#pragma mark - ETALocationMapDelegate
- (CLLocation*)provideDefaultLocation {
// testing code: 37.409254,-121.962303 around 2111 Tasman Dr, Santa Clara
    CLLocation* location = [[CLLocation alloc] initWithLatitude:37.409254 longitude:-121.962303];
    
    return location;
}

- (void)ETALocationMapView:(ETALocationMapViewController *)ETALocationMapView didSelectedLocation:(CLLocation *)location {
    if (location) {
        NSString* latLongString = [NSString stringWithFormat:@"%3.5f, %3.5f", location.coordinate.latitude, location.coordinate.longitude];
        self.textDestination.text = latLongString;
    }
}

@end
