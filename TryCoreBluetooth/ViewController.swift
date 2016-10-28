//  ViewController.swift
//  TryCoreBluetooth

import UIKit
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



class ViewController: UIViewController, BLEManagerDelegate {
    
    @IBOutlet weak var turnSignalControl: UISegmentedControl!
    
    @IBOutlet weak var laserLightControl: UISegmentedControl!
    
    @IBOutlet weak var redLightControl: UISegmentedControl!
    
    var didDiscoverCharacteristic = false // need more than this it's a start towards fixing the MVC masive view controller pattern

    let bleManager = BLEManager()
    
    /****
    var centralManager :CBCentralManager!
    var peripheral :CBPeripheral!
    var peripherals: Array<CBPeripheral> = Array<CBPeripheral>()
    
    var lightCharacterstic :CBCharacteristic?

    let serviceID  = CBUUID(string: "FFF0")
    let characteristicID = CBUUID(string: "FFF2")  // 0x not needed as prefix here
 ***********/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start BLE central manager
       // centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        bleManager.delegate = self
    }

    /**
    // required
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("the one, the only: required delegate method for CBCentralMamager")
        
        /**** CBManagerState.poweredOff, CBManagerState.resetting, CBManagerState.unauthorized
              CBManagerState.unknown, CBManagerState.unsupported ******/
        
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
                 self.peripheral.delegate = self
                 centralManager.connect(peripheral, options: nil)
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
        
        let theService :[CBUUID] = [serviceID]
        
        // use [CBUDID] to limit services
         peripheral.discoverServices(nil)
        // didDiscover services callback is called on return of the above call
        
    }
    
    /*** [CoreBluetooth] API MISUSE: <private> has no restore identifier but the delegate implements the centralManager:willRestoreState: method. Restoring will not be supported
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("will restore state")
     }
     *****/
    
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
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    // peripheral delegate
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        print("perph did update name")
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
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("did Read RSSI")  // RSSI measures signal strength
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("did modify services")
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
    
    // descriptor?
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
            print("did update val descriptor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("did discover descriptors for")
    }
    
    // this get called after call to discoverCharatertics in did discover services completes
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("did discover characterstics")
        print("characterstics found = \(service.characteristics)")
        
        if let characteristics = service.characteristics
        {
            var enableValue :UInt8 = 2 // on
           
           // var sendData = NSData(bytes: [0x00, 0x00, 0x02, 0x00, 0x00, 0x00] as [UInt8], length: 6)
            
            // [0] turn signal
            // [1] laser light 
            // [2]nothing
            // [3] nothing 
            // [4] is RED Light
            // [5] all steady on 0x02
            
            
            var sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x02] as [UInt8], length: 6)

            
         //   let enableBytes = NSData(bytes: &enableValue, length: MemoryLayout<UInt8>.size)
            
            for characteristic in characteristics
            {
                if characteristic.uuid == characteristicID
                {
                    lightCharacterstic = characteristic
                   // peripheral.readValue(for: characteristic)
                    
                    
                   // peripheral.writeValue(sendData as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
               
                }
            }
        }
        
        
        
        // setNotifyValue here to get changes to val privided in didUpdateValueForCharaterstic delegate method or readValue or writeValue
        
        // -- SOME methods/properties of intersest
        // peripheral.readValue
        // peripheral.writeValue
        // peripheral.setNotifyValue
        
        /****
        service.characteristics[0].isNotifying
        service.characteristics[0].descriptors
        service.characteristics[0].properties
        service.characteristics[0].value
        
        //peripheral.readValue(for: )
        peripheral.writeValue(data, for: )
        CBCharacteristicWriteType.withoutResponse
        CBCharacteristicWriteType.withResponse
        
        peripheral.writeValue(data, for: cbchar, type: writetype)
        peripheral.readValue(for: <#T##CBCharacteristic#>)
        
        peripheral.setNotifyValue(<#T##enabled: Bool##Bool#>, for: <#T##CBCharacteristic#>)
        peripheral.state
 
         *****/
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("didDiscoverIncludedServicesFor")
    }
    
    // check this on write please!!!!
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("idUpdateNotificationStateFor")
    }
    *****/
    
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
        
        bleManager.writeDataToLight(sendData: sendData)
        
        // peripheral.writeValue(sendData as Data, for: lightCharacterstic!, type: CBCharacteristicWriteType.withResponse)
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
        
        bleManager.writeDataToLight(sendData: sendData)
       // peripheral.writeValue(sendData as Data, for: lightCharacterstic!, type: CBCharacteristicWriteType.withResponse)
        
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
        
        bleManager.writeDataToLight(sendData: sendData)
        
      //  peripheral.writeValue(sendData as Data, for: lightCharacterstic!, type: CBCharacteristicWriteType.withResponse)

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

        bleManager.writeDataToLight(sendData: sendData)
      //  peripheral.writeValue(sendData as Data, for: lightCharacterstic!, type: CBCharacteristicWriteType.withResponse)
        
        print("DID Call Write Value with all 0's")

    }
    
    

}

