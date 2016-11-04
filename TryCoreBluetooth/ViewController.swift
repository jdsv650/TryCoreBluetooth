//  ViewController.swift
//  TryCoreBluetooth

/****
 CoreMotion Event frequency (Hz) - Usage
 Usage
 10–20
 Suitable for determining a device’s current orientation vector.
 30–60
 Suitable for games and other apps that use the accelerometer for real-time user input.
 70–100
 Suitable for apps that need to detect high-frequency motion. For example, you might use this interval to detect the user hitting the device or shaking it very quickly.
 
 let fastestUpdate = 0.01  --- 100hz
 
  // 0.10s  10 hz
  // 0.05s  20 hz
  // 0.02s  50 hz
  // 0.01s  100hz
 ****/



import UIKit
import CoreBluetooth
import CoreMotion

class ViewController: UIViewController, BLEManagerDelegate {
    
    @IBOutlet weak var turnSignalControl: UISegmentedControl!
    @IBOutlet weak var laserLightControl: UISegmentedControl!
    @IBOutlet weak var redLightControl: UISegmentedControl!
    
    @IBOutlet weak var coloredBoxLabel: UILabel!
    
    
    var didDiscoverCharacteristic = false // need more than this it's a start towards fixing the MVC masive view controller pattern

    let bleManager = BLEManager() // * starts the CB manager *
    let motionManager = CMMotionManager()
    
  //  let fastestUpdate = 0.01
    var refreshRate = 0.01

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateProximitySensor()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        coloredBoxLabel.isHidden = true
        
       // motionManager.deviceMotion?.userAcceleration.x
        
        if motionManager.isGyroAvailable
        {
            motionManager.gyroUpdateInterval = refreshRate
            
            let queue = OperationQueue.main
            
            motionManager.startGyroUpdates(to: queue) {
                (data, error) in
                
                if error != nil
                {
                    print(error?.localizedDescription)
                    return
                }
                
                if let theData = data
                {
                    print("x = \(theData.rotationRate.x)")
                    print("y = \(theData.rotationRate.y)")
                    print("z = \(theData.rotationRate.z)")
                    
                    // hmmm do something based on this
                }
            }
         }
        
    
        if motionManager.isAccelerometerAvailable
        {
            motionManager.accelerometerUpdateInterval = refreshRate
            
            let queue = OperationQueue.main
            motionManager.startAccelerometerUpdates(to: queue) {
                (data, error) in
                
                if error != nil
                {
                    print(error?.localizedDescription)
                    return
                }
                
                if let theData = data
                {
                    
                    print("x = \(theData.acceleration.x)")
                    print("y = \(theData.acceleration.y)")
                    print("z = \(theData.acceleration.z)")
                    
                    // do soemthing here
                    if theData.acceleration.x < -2.5
                        || theData.acceleration.y < -2.5
                        || theData.acceleration.y > 2.5
                    {
                        self.coloredBoxLabel.isHidden = false
                    }
        
                    
                }
            }
        }
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
    
    
    var isRedLightOn :UInt8 = 0x01

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
        case 0: // ignore
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8], length: 6)
        case 1: //off
                sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x01, 0x00] as [UInt8], length: 6)
                isRedLightOn = 0x01
        case 2: // on
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x02, 0x00] as [UInt8], length: 6)
            isRedLightOn = 0x02
        case 3: // flash
            isRedLightOn = 0x02
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x00, 0x03, 0x00] as [UInt8], length: 6)
        case 4:
            // brake light on
            sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x64, 0x02, 0x00] as [UInt8], length: 6)
        case 5: //brake light off
                sendData = NSData(bytes: [0x00, 0x00, 0x00, 0x32, isRedLightOn, 0x00] as [UInt8], length: 6)
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
    
    
    
    @IBAction func removePressed(_ sender: UIButton)
    {
        coloredBoxLabel.isHidden = true
        
    }
    
    
    func proximityChanged(notification: NSNotification) {
        if let device = notification.object as? UIDevice {
            print("\(device) detected!")
        }
    }
    
    func activateProximitySensor() {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        if device.isProximityMonitoringEnabled {
            NotificationCenter.default.addObserver(self, selector: Selector(("proximityChanged:")), name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: device)
        }
    }


}

