//
//  mclViewController.m
//  iBeaconReceiver
//
//  Created by Mike Calvert on 20/05/2014.
//  Copyright (c) 2014 Mckenna Consultants. All rights reserved.
//

#import "mclViewController.h"

@interface mclViewController ()

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UILabel *intermediateLabel;
@property (strong, nonatomic) IBOutlet UILabel *nearLabel;
@property (strong, nonatomic) IBOutlet UILabel *farLabel;
@property (strong, nonatomic) IBOutlet UILabel *unknownLabel;

@end

@implementation mclViewController

- (IBAction)unwindHandler:(id)sender {
    
}

- (IBAction)startHandler:(id)sender {
    [self initLocationManager];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //[self initLocationManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initLocationManager {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusRestricted ||
        status == kCLAuthorizationStatusDenied) {
        self.statusLabel.text = @"Not authorised";
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
        [CLLocationManager locationServicesEnabled];
    } else if (status == kCLAuthorizationStatusAuthorizedAlways ||
               status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.statusLabel.text = @"Waiting for authorisation";
        [self startSearchingForBeacons];
    } else {
        self.statusLabel.text = @"Something aint right";
    }
}

- (void) startSearchingForBeacons {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"C08FF959-04B7-4603-8860-018AC72C95E1"];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.mckennaconsultants.ibeacon"];
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    self.statusLabel.text = @"Searching for beacons...";
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startSearchingForBeacons];
    } else if (status == kCLAuthorizationStatusRestricted ||
               status == kCLAuthorizationStatusDenied) {
        self.statusLabel.text = @"Not authorised";
    }
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    self.statusLabel.text = @"Beacons in range";
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.statusLabel.text = @"Beacons out of range";
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
    if ([beacons count] > 0) {
        CLBeacon *nearestBeacon = nil;
        
        for (CLBeacon *foundBeacon in beacons) {
            // You can retrieve the beacon data from its properties
            //NSString *uuid = foundBeacon.proximityUUID.UUIDString;
            //NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
            //NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
            
            if (nearestBeacon == nil) {
                nearestBeacon = foundBeacon;
            } else if (foundBeacon.accuracy < nearestBeacon.accuracy) {
               nearestBeacon = foundBeacon;
            }
        }
        
        if (nearestBeacon != nil) {
            NSString *major = [NSString stringWithFormat:@"%@", nearestBeacon.major];
            NSString *minor = [NSString stringWithFormat:@"%@", nearestBeacon.minor];
            self.statusLabel.text = [NSString stringWithFormat:@"Nearest beacon %@.%@. Range: %f", major, minor, nearestBeacon.accuracy];
            [self setProximity:nearestBeacon.proximity];
        }
        
    } else {
        self.statusLabel.text = @"No beacons found";
        [self resetProximity];
    }
}

- (void) resetProximity {
    [self.unknownLabel setTextColor:[UIColor whiteColor]];
    [self.farLabel setTextColor:[UIColor whiteColor]];
    [self.nearLabel setTextColor:[UIColor whiteColor]];
    [self.intermediateLabel setTextColor:[UIColor whiteColor]];
}

- (void) setProximity:(CLProximity)proximity {
    [self.unknownLabel setTextColor:proximity == CLProximityUnknown ? [UIColor blueColor] : [UIColor whiteColor]];
    [self.farLabel setTextColor:proximity == CLProximityFar ? [UIColor redColor] : [UIColor whiteColor]];
    [self.nearLabel setTextColor:proximity == CLProximityNear ? [UIColor orangeColor] : [UIColor whiteColor]];
    [self.intermediateLabel setTextColor:proximity == CLProximityImmediate ? [UIColor greenColor] : [UIColor whiteColor]];
}
@end
