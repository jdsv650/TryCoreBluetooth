//  ViewController.swift
//  TryCoreBluetooth

import UIKit
import CoreBluetooth

class ViewController: UIViewController, BLEManagerDelegate {
    
    @IBOutlet weak var turnSignalControl: UISegmentedControl!
    @IBOutlet weak var laserLightControl: UISegmentedControl!
    @IBOutlet weak var redLightControl: UISegmentedControl!
    
    var didDiscoverCharacteristic = false // need more than this it's a start towards fixing the MVC masive view controller pattern

    let bleManager = BLEManager() // * starts the CB manager *

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // optional delegate funcs to stay informed of Bluetooth status
        bleManager.delegate = self
    }

    func centralDidDiscoverPeripheral(isFound: Bool) {
        print("")
    }
    
    func centralDidDiscoverCharacteristic(isFound: Bool) {
        
        didDiscoverCharacteristic = isFound
        
    }
    
    func centralDidUpdateStatus(status: CBManagerState) {
        print("")
        if status == CBManagerState.poweredOn
        {
            
        }
        else
        {
            // inform user try again etc.....
        }
        
    }
    
    
    @IBAction func turnSignalControlPresssed(_ sender: UISegmentedControl) {
        
        /****
        
        if peripheral == nil { print("peripheral not connected") ; return }
        
        // are we still connected?
         if peripheral.state != .connected {
            print("Peripheral is not connected")
            self.peripheral = nil
            return
        }
        
        // did we find the characteristic to work with?
        if lightCharacterstic == nil { return }
 *******/
        
        if !didDiscoverCharacteristic == true
        {
            print("Not cnnected or can't access characeristic")
            return
        }
 
        var sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        
        switch sender.selectedSegmentIndex {
        case 0:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 1:
            sendData = NSData(bytes: [0x01, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 2:
            sendData = NSData(bytes: [0x02, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 3:
            sendData = NSData(bytes: [0x03, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 4:
            sendData = NSData(bytes: [0x04, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        default:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        }
        
        let result = bleManager.writeDataToLight(sendData: sendData)
        if !result { print("write failed") }
        
    }
    
    
    @IBAction func laserLightControlpressed(_ sender: UISegmentedControl) {
        
        if !didDiscoverCharacteristic == true
        {
            print("Not cnnected or can't access characeristic")
            return
        }
        
        /***
        if peripheral == nil { print("peripheral not connected") ; return }

        // are we still connected?
        if peripheral.state != .connected {
            print("Peripheral is not connected")
            self.peripheral = nil
            return
        }
        
        // did we find the characteristic to work with?
        if lightCharacterstic == nil { return }
 ****/
        
        var sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        
        switch sender.selectedSegmentIndex {
        case 0:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 1:
            sendData = NSData(bytes: [0x00, 0x01, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 2:
            sendData = NSData(bytes: [0x00, 0x02, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        default:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        }
        
        let result = bleManager.writeDataToLight(sendData: sendData)
        if !result { print("write failed") }
   
    }
    
    
    
    @IBAction func redLightControlPressed(_ sender: UISegmentedControl) {
        
        if !didDiscoverCharacteristic == true
        {
            print("Not cnnected or can't access characeristic")
            return
        }
        
        /***
        if peripheral == nil { print("peripheral not connected") ; return }
        
        // are we still connected?
        if peripheral.state != .connected {
            print("Peripheral is not connected")
            self.peripheral = nil
            return
        }
        
        // did we find the characteristic to work with?
        if lightCharacterstic == nil { return }
 
  *****/
        var sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        
        switch sender.selectedSegmentIndex {
        case 0:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 1:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x01, 0x00] as [UInt8], length: 6)
        case 2:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x02, 0x00] as [UInt8], length: 6)
        case 3:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x03, 0x00] as [UInt8], length: 6)
        default:
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        }
        
        let result = bleManager.writeDataToLight(sendData: sendData)
        if !result { print("write failed") }
    }
    
    
    @IBAction func lightsOutPressed(_ sender: UIButton) {
        
        
        if !didDiscoverCharacteristic == true
        {
            print("Not cnnected or can't access characeristic")
            return
        }
        
        /***
        if peripheral == nil { print("peripheral not connected") ; return }
        
        // are we still connected?
        if peripheral.state != .connected {
            print("Peripheral is not connected")
            self.peripheral = nil
            return
        }
        
        // did we find the characteristic to work with?
        if lightCharacterstic == nil { return }  ****/
        
        // this makes more sense why the 0'd fields were not changing other light states
        // * 0 is "ignore" the state we pass in for that particular attribute  *
        let sendData = NSData(bytes: [0x01, 0x01, 0x00, 0x00, 0x01, 0x00] as [UInt8], length: 6)

        let result = bleManager.writeDataToLight(sendData: sendData)
        if !result { print("write failed") }

    }
    
    

}

