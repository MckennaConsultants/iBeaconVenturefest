//
//  mclBeaconManager.m
//  HideAndSeek
//
//  Created by Mike Calvert on 02/06/2014.
//  Copyright (c) 2014 Mckenna Consultants. All rights reserved.
//

#import "mclBeaconManager.h"

@interface mclBeaconManager()

@property (strong, nonatomic) NSUUID *broadcastUUID;
@property (strong, nonatomic) NSString *regionIdentifier;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CLLocationManager *locationManager;

// C08FF959-04B7-4603-8860-018AC72C95E1

@end

@implementation mclBeaconManager

#pragma mark - Broadcasting

- (mclBeaconManager *) initWithUUID:(NSString *)uuid AndRegionIdentifier:(NSString *)regionIdentifier {
    self = [super init];
    if (self) {
        self.broadcastUUID = [[NSUUID alloc] initWithUUIDString:uuid];
        self.regionIdentifier = regionIdentifier;
    }
    return self;
}

-(void) broadcast {
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.broadcastUUID major:1 minor:1 identifier:self.regionIdentifier];
    self.beaconData = [self.beaconRegion peripheralDataWithMeasuredPower:nil];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        // Bluetooth is on
        [self.peripheralManager startAdvertising:self.beaconData];
        if (self.startedBroadcasting != nil) {
            self.startedBroadcasting();
        }
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff){
        // Bluetooth is off
        [self.peripheralManager stopAdvertising];
        if (self.stoppedBroadcasting != nil) {
            self.stoppedBroadcasting();
        }
    }
}

#pragma mark - Receiver logic

-(void) receive {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.broadcastUUID identifier:self.regionIdentifier];
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    if (self.enteredRegion != nil) {
        self.enteredRegion();
    }
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    if (self.exitedRegion != nil) {
        self.exitedRegion();
    }
}

-(void)locationManager:(CLLocationManager*)manager didRangeBeacons:(NSArray*)beacons inRegion:(CLBeaconRegion*)region
{
    CLBeacon *foundBeacon = [beacons firstObject];
    if (foundBeacon != nil) {
        if (self.proximityUpdated != nil) {
            self.proximityUpdated(foundBeacon.proximity, foundBeacon.accuracy);
        }
    }
}

@end
