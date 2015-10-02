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
#import "ETAConfigTableViewController.h"
#import "AppDelegate.h"

@interface ViewController () <ETALocationMapDelegate, ETATrackingViewDelegate, ETAConfigSelectDelegate, UITextFieldDelegate, UIAlertViewDelegate>

/* UI Elements*/
@property (weak, nonatomic) IBOutlet UITextField *textDestination;
@property (weak, nonatomic) IBOutlet UISlider *slideETA;
@property (weak, nonatomic) IBOutlet UILabel *textETA;
@property (weak, nonatomic) IBOutlet UITextField *textNumber;
@property (weak, nonatomic) IBOutlet UITextField *textMessage;

@end

static NSString* defaultConfigName = @"ETADefaultConfigs";

@implementation ViewController {
    BOOL m_bJustfire;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self _prepareMainView];
    
    m_bJustfire = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAtoptechShortcut:) name:ETAShortcutNotificationAtoptech object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleJustFireShortcut:) name:ETAShortcutNotificationJustFire object:nil];
}

- (void)handleAtoptechShortcut:(NSNotification*)notification {
    /* hardcode everything! */
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textDestination.text = @"37.40874, -121.96320";
        self.slideETA.value = 3.0f;
        self.textNumber.text = @"6262153417";
        self.textMessage.text = @"哈囉親愛的 收書包準備下班 老公三分鐘後到";
        
        [self btnStartTrackingClicked:nil];
    });
}

- (void)handleJustFireShortcut:(NSNotification*)notification {
    self.textDestination.text = @"37.40874, -121.96320";
    self.slideETA.value = 3.0f;
    self.textNumber.text = @"6262153417";
    self.textMessage.text = @"哈囉親愛的 收書包準備下班 老公三分鐘後到";
    
    m_bJustfire = YES;
    [self btnStartTrackingClicked:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_prepareMainView {
    self.textDestination.delegate = self;
    self.textNumber.delegate = self;
    self.textMessage.delegate = self;
    
    self.textDestination.text = @"37.383358, -122.079962";//@"37.783486, -122.396147";//@"37.409254, -121.962303";
    self.textNumber.text = @"626-461-2675";//@"626-215-3417";
    self.textMessage.text = @"Hoot Hoot! Twilions :)";//@"Hey Sweetheart. ETA 3 Minutes!";
}

- (BOOL)isGoodToStart {
    BOOL bGoodToGo = NO;
    return bGoodToGo;
}

- (void)_initDefaultConfig {
    
}

#pragma mark - button functions & IBActions
- (IBAction)onETASlided:(id)sender {
    UISlider* etaSlider = (UISlider*)sender;
    self.textETA.text = [NSString stringWithFormat:@"%lu", (unsigned long)(etaSlider.value)];
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
    trackingVC.bFireImmediately = m_bJustfire;
    m_bJustfire = NO;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:trackingVC];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (IBAction)btnSaveConfigClicked:(id)sender {
    UIAlertView* saveAlert = [[UIAlertView alloc] initWithTitle:@"Save Config"
                                                        message:@"Enter friendly name for the config"
                                                       delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    
    saveAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* alertTextField = [saveAlert textFieldAtIndex:0];
    alertTextField.clearButtonMode = UITextFieldViewModeAlways;
    alertTextField.returnKeyType = UIReturnKeyDone;
    
    saveAlert.tag = 9999;
    [saveAlert show];
}

- (void)_postSaveTaskWithConfigName:(NSString*)configName {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:defaultConfigName]) {
        [self _initDefaultConfig];
    }
    
    NSArray* defaultConfigArray = [[NSUserDefaults standardUserDefaults] objectForKey:defaultConfigName];
    NSMutableArray* updatedConfigArray = ([defaultConfigArray count])? [defaultConfigArray mutableCopy] : [NSMutableArray arrayWithCapacity:0];
    
    NSDictionary* newConfig = @{ @"name" : configName,
                                 @"destination" : self.textDestination.text,
                                 @"eta" : [NSNumber numberWithInt:self.slideETA.value],
                                 @"number" : self.textNumber.text,
                                 @"message" : self.textMessage.text };
    [updatedConfigArray insertObject:newConfig atIndex:0];
    
    [[NSUserDefaults standardUserDefaults] setObject:updatedConfigArray forKey:defaultConfigName];
    
    UIAlertView* doneAlert = [[UIAlertView alloc] initWithTitle:@"Ahoy" message:@"Config saved."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [doneAlert show];
}

- (IBAction)btnLoadConfigClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ETAConfigTableViewController* configVC = [storyboard instantiateViewControllerWithIdentifier:@"ETAConfigTableViewController"];
    configVC.delegate = self;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:configVC];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - ETALocationMapDelegate
- (CLLocation*)provideDefaultLocation {
    NSString* destination = self.textDestination.text;
    NSArray* latLongArray = [destination componentsSeparatedByString:@","];
    if ([destination length] > 0 && [latLongArray count] == 2) {
        CLLocation* location = [[CLLocation alloc] initWithLatitude:[latLongArray[0] floatValue]
                                                          longitude:[latLongArray[1] floatValue]];
        
        return location;
    }
    else {
        return nil;
    }
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

#pragma mark - ETAConfigSelectDelegate
- (NSArray*)provideDefaultConfigs {
    NSArray* configArray = [[NSUserDefaults standardUserDefaults] objectForKey:defaultConfigName];
    return configArray;
}

- (void)didSelectDefaultConfid:(NSDictionary *)configDict {
    NSString* name = configDict[@"name"];
    if ([name length] > 0) {
        self.title = name;
    }
    
    NSString* destination = configDict[@"destination"];
    self.textDestination.text = destination;
    NSNumber* etaMinutes = configDict[@"eta"];
    self.slideETA.value = [etaMinutes floatValue];
    self.textETA.text = [NSString stringWithFormat:@"%lu", (NSUInteger)(self.slideETA.value)];
    NSString* number = configDict[@"number"];
    self.textNumber.text = number;
    NSString* message = configDict[@"message"];
    self.textMessage.text = message;
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
    alertTextField.returnKeyType = UIReturnKeyDone;
    
    /* in order to separate it from the test-field of number & message in the delegate */
    inputAlertView.tag = (textField == self.textNumber)? 1234 : 5678;
    
    [inputAlertView show];
    
    return NO;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        UITextField* textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] > 0) {
            if (alertView.tag == 1234) {
                /* for "number" */
                self.textNumber.text = textField.text;
            }
            else if (alertView.tag == 5678) {
                /* for "message" */
                self.textMessage.text = textField.text;
            }
            else if (alertView.tag == 9999) {
                /* for "save" */
                [self _postSaveTaskWithConfigName:textField.text];
            }
        }
    }
}

@end
