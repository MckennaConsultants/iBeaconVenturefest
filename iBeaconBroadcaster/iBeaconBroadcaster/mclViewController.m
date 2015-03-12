//
//  mclViewController.m
//  iBeaconBroadcaster
//
//  Created by Mike Calvert on 20/05/2014.
//  Copyright (c) 2014 Mckenna Consultants. All rights reserved.
//

#import "mclViewController.h"

@interface mclViewController ()

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *broadcastButton;
@property (strong, nonatomic) CLBeaconRegion *myBeaconRegion;
@property (strong, nonatomic) NSDictionary *myBeaconData;
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@end

@implementation mclViewController
{
    BOOL broadcasting;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"C08FF959-04B7-4603-8860-018AC72C95E1"];
    self.myBeaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:1 minor:1 identifier:@"com.mckennaconsultants.ibeacon"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)broadcastButtonTouchUpInside:(id)sender {
    if (!broadcasting) {
        self.myBeaconData = [self.myBeaconRegion peripheralDataWithMeasuredPower:nil];
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        [self.broadcastButton setHidden:YES];
        broadcasting = true;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        // Bluetooth is on
        [self.peripheralManager startAdvertising:self.myBeaconData];
        self.statusLabel.text = @"Broadcasting...";
    }
    else if (peripheral.state == CBPeripheralManagerStatePoweredOff){
        [self.peripheralManager stopAdvertising];
        self.statusLabel.text = @"Not broadcasting...";
    }
    else if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        self.statusLabel.text = @"Device does not support broadcasting!";
    }
    
}

@end
