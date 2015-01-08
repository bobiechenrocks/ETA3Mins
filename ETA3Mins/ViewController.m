//
//  ViewController.m
//  ETA3Mins
//
//  Created by bobiechen on 1/6/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ViewController.h"
#import "ETALocationMapViewController.h"
#import "ETATrackingViewController.h"

@interface ViewController () <ETALocationMapDelegate, ETATrackingViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

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
    
    [self _prepareMainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_prepareMainView {
    self.textDestination.delegate = self;
    self.textNumber.delegate = self;
    self.textMessage.delegate = self;
    
    self.textDestination.text = @"37.409254, -121.962303";
    self.textNumber.text = @"626-215-3417";
    self.textMessage.text = @"Hey Sweetheart. ETA 3 Minutes";
}

- (BOOL)isGoodToStart {
    BOOL bGoodToGo = NO;
    return bGoodToGo;
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
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ETATrackingViewController* trackingVC = [storyboard instantiateViewControllerWithIdentifier:@"ETATrackingViewController"];
    trackingVC.delegate = self;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:trackingVC];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
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

#pragma mark - ETATrackingViewDelegate
- (NSDictionary*)provideTrackingTaskInfo {
    NSArray* latLongArray = [self.textDestination.text componentsSeparatedByString:@","];
    CLLocation* destinationLocation = nil;
    if ([latLongArray count] == 2) {
        destinationLocation = [[CLLocation alloc] initWithLatitude:[(latLongArray[0]) floatValue] longitude:[(latLongArray[1]) floatValue]];
    }
    
    if (destinationLocation == nil || [self.textNumber.text length] <= 0 || [self.textMessage.text length] <= 0) {
        return nil;
    }
    
    NSDictionary* trackingTaskInfo = @{ @"destination" : destinationLocation,
                                        @"eta" : [NSNumber numberWithFloat:self.slideETA.value],
                                        @"number" : self.textNumber.text,
                                        @"message" : self.textMessage.text };
    return trackingTaskInfo;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.textDestination) {
        return NO;
    }
    
    NSString* alertTitle = (textField == self.textNumber)? @"SMS Number" : @"SMS Message";
    UIAlertView* inputAlertView = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self
                                                   cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    inputAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* alertTextField = [inputAlertView textFieldAtIndex:0];
    alertTextField.text = textField.text;
    alertTextField.clearButtonMode = UITextFieldViewModeAlways;
    if (textField == self.textNumber) {
        alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    alertTextField.returnKeyType = UIReturnKeyDone;
    
    /* in order to separate it from the test-field of number & message in the delegate */
    alertTextField.tag = (textField == self.textNumber)? 1234 : 5678;
    
    [inputAlertView show];
    
    return NO;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        UITextField* textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] > 0) {
            if (textField.tag == 1234) {
                /* for "number" */
                self.textNumber.text = textField.text;
            }
            else if (textField.tag == 5678) {
                /* for "message" */
                self.textMessage.text = textField.text;
            }
        }
    }
}

@end
