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

- (IBAction)startHandler:(id)sender {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"C08FF959-04B7-4603-8860-018AC72C95E1"];
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.mckennaconsultants.ibeacon"];
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon != nil) {
        // You can retrieve the beacon data from its properties
        //NSString *uuid = foundBeacon.proximityUUID.UUIDString;
        NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
        NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
    
        self.statusLabel.text = [NSString stringWithFormat:@"Beacon %@.%@ found. Range: %f", major, minor, foundBeacon.accuracy];
        [self setProximity:foundBeacon.proximity];
    }
    else {
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
