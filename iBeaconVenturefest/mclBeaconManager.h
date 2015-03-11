//
//  mclBeaconManager.h
//  HideAndSeek
//
//  Created by Mike Calvert on 02/06/2014.
//  Copyright (c) 2014 Mckenna Consultants. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@interface mclBeaconManager : NSObject<CBPeripheralManagerDelegate,CLLocationManagerDelegate>

// Broadcast callbacks
@property (copy) void (^startedBroadcasting)(void);
@property (copy) void (^stoppedBroadcasting)(void);

// Receiver callbacks
@property (copy) void (^enteredRegion)(void);
@property (copy) void (^exitedRegion)(void);
@property (copy) void (^proximityUpdated)(CLProximity proximity, CLLocationAccuracy distance);

// Methods
- (mclBeaconManager *) initWithUUID:(NSString *)uuid AndRegionIdentifier:(NSString *)regionIdentifier;
- (void) broadcast;
- (void) receive;

@end
