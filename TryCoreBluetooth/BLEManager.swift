//
//  BLEManager.swift
//  TryCoreBluetooth
//
//  Created by James on 10/27/16.
//  Copyright © 2016 James. All rights reserved.
//

import Foundation
import CoreBluetooth

// [0]
public enum TurnLighControl :UInt8 {
    case ignore
    case off
    case leftFlash
    case rightFlash
    case leftAndRightFlash
}

// [1]
public enum LaserLighControl :UInt8 {
    case ignore
    case off
    case on
}

// [4]
public enum RedLightControl :UInt8 {
    case ignore
    case off
    case on
    case flash
}

// [5]  seems to turn all lights on ?????????????????????? not documented ?????????/
public enum AllControl :UInt8 {
    // Only checked with 0x02 in this position and turns all on
    case ignore
    case off
    case on
    case flash
}


@objc protocol BLEManagerDelegate {
    @objc optional func centralDidUpdateStatus(status: CBManagerState)
    @objc optional func centralDidDiscoverPeripheral(isFound: Bool)
    @objc optional func centralDidDiscoverCharacteristic(isFound: Bool)
    
}


class BLEManager :NSObject, CBPeripheralDelegate, CBCentralManagerDelegate
{
    
    
    
    var delegate : BLEManagerDelegate?
    
    // need central (client) manager and peripheral (server)
    var centralManager :CBCentralManager!
    var peripheral :CBPeripheral?
    var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    
    var lightCharacterstic :CBCharacteristic?
    
    let serviceID  = CBUUID(string: "FFF0")
    let characteristicID = CBUUID(string: "FFF2")
    
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    // required
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {
        print("the one, the only: required delegate method for CBCentralMamager")
        
        /**** CBManagerState.poweredOff, CBManagerState.resetting, CBManagerState.unauthorized
         CBManagerState.unknown, CBManagerState.unsupported ******/
        
        // pass this on to the delegate (UI) so we know if bluetooth is available
        delegate?.centralDidUpdateStatus?(status: central.state)
        
        if (central.state == CBManagerState.poweredOn)
        {
            // limit scan by using withServices NOPE Not adverising services data don't do it
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {  /* do something like alert the user that ble is not on */ }
    }
    
    //rest are otional but required to do anything!
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        print("did discover peripheral with service \(serviceID)")
        
        // only getting ["kCBAdvDataIsConnectable": 1] from my macbook
        print("Found advertisement data = \(advertisementData)")
        
        //The light is advetising this if we want "kCBAdvDataLocalName": HandsFreeLight
        // was a no on my macbook
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            print("****************\(peripheralName)********************")
        }
        
        // this is coming back nil use below instead OK rhis was on macbook
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        if let theDevice = device { print("Device = \(theDevice)") }
        
        if let myDevice = device
        {
            if myDevice.contains("HandsFreeLight") == true
            {
                self.centralManager.stopScan()
                self.peripheral = peripheral
                self.peripheral?.delegate = self
                self.centralManager.connect(peripheral, options: nil)
                
                delegate?.centralDidDiscoverPeripheral?(isFound: true)
            }
        
        }
        // This is working the advertisised data above only seems to give kCBAdvDataIsConnectable
        // ok if no name changes I don't think we have to worry about this!!!!
        
        /**
         if let name = peripheral.name
         {
         if name == "James’s MacBook Pro" {
         // may want to do this later - the stopScan and setting delgate
         self.centralManager.stopScan()
         self.peripheral = peripheral
         self.peripheral.delegate = self
         centralManager.connect(peripheral, options: nil)
         }
         ****/
        
        // don't add same peripheral multiple times becuase you can
        if !peripherals.contains(peripheral)
        {
            peripherals.append(peripheral)
            
            for p in peripherals
            {
                print("Periph name = \(p.name)")
                print("Periph services = \(p.services)")
                print("Periph state \(p.state)")
            }
        }
    }
    
    // read this gets called on attempt to conect and we aren't necesarily connected and ready to go??????/
    // how many times does this connect lol - a steady stream not great
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("did connect peripheral")
        
        /****   Done Earlier but maybe move here WWDC video set delegate here???
         self.centralManager.stopScan()
         self.peripheral = peripheral
         self.peripheral.delegate = self
         ****/
        //let theService :[CBUUID] = [serviceID]
        
        // use [CBUDID] to limit services
        peripheral.discoverServices(nil)
        // didDiscover services callback is called on return of the above call
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("did fail to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("did disconnect hands free light")
        if error != nil {
            print("Disconnect from hands free with error: \(error!.localizedDescription)")
        }
        
        // clear any lights etc....
        self.peripheral = nil
        // try reconnect???
        self.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("did discover services")
        print("Service found on connection == \(peripheral.services)")
        
        if let services = peripheral.services
        {
            for service in services
            {
                if service.uuid == serviceID
                {
                    // get all characterstics
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error?.localizedDescription)
        }
        else
        {
            print("Did Write TO Device for characterstic = \(characteristic)")
            print("Did Write value TO Device for characterstic = \(characteristic.value)")
        }
    }
    
    // called after we setNotifyValue true on a characteristic or read
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("did update value for")
        
        print("characteristic.value = \(characteristic.value![4])")
    }
    
    // descriptor ?
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("did wrie value for")
    }
    

    // this get called after call to discoverCharatertics in did discover services completes
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("did discover characterstics")
        print("characterstics found = \(service.characteristics)")
        
        if let characteristics = service.characteristics
        {
            // var sendData = NSData(bytes: [0x00, 0x00, 0x02, 0x00, 0x00, 0x00] as [UInt8], length: 6)
            // [0] turn signal
            // [1] laser light
            // [2]nothing
            // [3] nothing
            // [4] is RED Light
            // [5] all steady on 0x02
            
            for characteristic in characteristics
            {
                if characteristic.uuid == characteristicID
                {
                    lightCharacterstic = characteristic
                    delegate?.centralDidDiscoverCharacteristic?(isFound: true)
                }
                else
                {
                    // perip oops
                  //  delegate?.centralDidDiscoverPeripheral?(isFound: false)
                }
            }
        }
    }

    
    func writeDataToLight(sendData: NSData) -> Bool // this should return some more info to help caller....
    {
        // must be 6 bytes
       // if theData.count != 6 { return false }
        
        if !isPeripheralConnected() { return false }
        
        // did we find the characteristic to work with?
        if !isCharactersticFound() { return false }
        
        // this makes more sense why the 0'd fields were not changing other light states
        // * 0 is "ignore" the state we pass in for that particular attribute  *
       // let sendData = NSData(bytes: [0x01, 0x01, 0x00, 0x00, 0x01, 0x00] as [UInt8], length: 6)
       // let sendData = NSData(bytes: theData, length: 6)
        
        peripheral?.writeValue(sendData as Data, for: lightCharacterstic!, type: CBCharacteristicWriteType.withResponse)
        
        print("DID Call Write Value with all 0's")
        return true
    }
    
     func isPeripheralConnected() -> Bool
    {
        if peripheral == nil { print("peripheral not connected") ; return false }
        if peripheral?.state != .connected
        {
            print("Peripheral is not connected")
            self.peripheral = nil
            return false
        }
        return true
    }
    
    func isCharactersticFound() -> Bool
    {
        if lightCharacterstic == nil { return false }
        
        return true
    }

}
