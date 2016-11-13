//
//  CMBrakeLightManager.swift
//  TryCoreBluetooth
//
//  Created by James on 11/12/16.
//  Copyright © 2016 James. All rights reserved.
//

import UIKit
import CoreMotion

protocol CMBrakeLightManagerDelegate {
    func brakeLightStatusChanged(isBrakeOn: Bool)
}

class CMBrakeLightManager: NSObject {
    
    var delegate: CMBrakeLightManagerDelegate?
    
    let motionManager = CMMotionManager() // CoreMotion Motion Manager for the accelerometer values
    
    let accelerometerUpdateInterval = 0.1   // 10x per second
    
    var firstAccelerometerData = true // indicates the first time accelerometer data received
    // low-pass filtering
    var previousXValue: Double!
    var previousYValue: Double!
    var previousZValue: Double!
    var xAcceleration: Double!
    var yAcceleration: Double!
    var zAcceleration: Double!
    var filteredXAcceleration: Double = 0.0
    var filteredYAcceleration: Double = 0.0
    var filteredZAcceleration: Double = 0.0
    
    let roundingPrecision = 3
    var accelerometerDataInEuclideanNorm: Double = 0.0
    var accelerometerDataCount: Double = 0.0
    var accelerometerDataInASecond = [Double]()
    var totalAcceleration: Double = 0.0
    var lowPassFilterPercentage = 15.0
    var shouldApplyFilter = true
    var staticThreshold = 0.013
    let slowWalkingThreshold = 0.05
    
    
    override init() {
        super.init()
        
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
        
       // motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: )
        
        // Initiate accelerometer updates
        motionManager.startAccelerometerUpdates(to: OperationQueue.main
        ) { (accelerometerData, error) -> Void in
            if((error) != nil) {
                print(error!)
            } else {
                self.estimateBrakeStatus(acceleration: (accelerometerData?.acceleration)!)
            }
        }
    }
    
    var startResult :Double?
    var endResult :Double?
    var startTime = NSDate()
    
    // original code from https://github.com/cansurmeli/pedestrian-status
    func estimateBrakeStatus(acceleration: CMAcceleration) {
        // If it's the first time accelerometer data obtained,
        // get old values as zero since there was no data before.
        // Otherwise get the previous value from the cycle before.
        // This is done for the purpose of the low-pass filter.
        // It requires the previous cycle data.
        if firstAccelerometerData {
            previousXValue = 0.0
            previousYValue = 0.0
            previousZValue = 0.0
            
            firstAccelerometerData = false
        } else {
            previousXValue = filteredXAcceleration
            previousYValue = filteredYAcceleration
            previousZValue = filteredZAcceleration
        }
        
        // Retrieve the raw x-axis value and apply low-pass filter on it
        xAcceleration = acceleration.x.roundTo(precision: roundingPrecision)
        // print("Raw X: \(xAcceleration)")
        filteredXAcceleration = xAcceleration.lowPassFilter(filterFactor: lowPassFilterPercentage, previousValue: previousXValue).roundTo(precision: roundingPrecision)
        // print("Filtered X: \(filteredXAcceleration)")
        
        // Retrieve the raw y-axis value and apply low-pass filter on it
        yAcceleration = acceleration.y.roundTo(precision: roundingPrecision)
        //  print("Raw Y: \(yAcceleration)")
        filteredYAcceleration = yAcceleration.lowPassFilter(filterFactor: lowPassFilterPercentage, previousValue: previousYValue).roundTo(precision: roundingPrecision)
        //  print("Filtered Y: \(filteredYAcceleration)")
        
        // Retrieve the raw z-axis value and apply low-pass filter on it
        zAcceleration = acceleration.z.roundTo(precision: roundingPrecision)
        //  print("Raw Z: \(zAcceleration)")
        filteredZAcceleration = zAcceleration.lowPassFilter(filterFactor: lowPassFilterPercentage, previousValue: previousZValue).roundTo(precision: roundingPrecision)
        //print("Filtered Z: \(filteredZAcceleration)\n")
        
        // EUCLIDEAN NORM CALCULATION
        // Take the squares to the low-pass filtered x-y-z axis values
        let xAccelerationSquared = (filteredXAcceleration * filteredXAcceleration).roundTo(precision: roundingPrecision)
        let yAccelerationSquared = (filteredYAcceleration * filteredYAcceleration).roundTo(precision: roundingPrecision)
        let zAccelerationSquared = (filteredZAcceleration * filteredZAcceleration).roundTo(precision: roundingPrecision)
        
        // Calculate the Euclidean Norm of the x-y-z axis values
        accelerometerDataInEuclideanNorm = sqrt(xAccelerationSquared + yAccelerationSquared + zAccelerationSquared)
        
        // Significant figure setting for the Euclidean Norm
        accelerometerDataInEuclideanNorm = accelerometerDataInEuclideanNorm.roundTo(precision: roundingPrecision)
        
        // EUCLIDEAN NORM VARIANCE CALCULATION
        // record 10 values
        // meaning values in a second
        // accUpdateInterval(0.1s) * 10 = 1s
        while accelerometerDataCount < 1 {
            accelerometerDataCount += 0.1
            
            accelerometerDataInASecond.append(accelerometerDataInEuclideanNorm)
            totalAcceleration += accelerometerDataInEuclideanNorm
            
            break	// required since we want to obtain data every acc cycle
            // otherwise goes to infinity
        }
        
        // when accelerometer values are recorded
        // interpret them
        if accelerometerDataCount >= 1 {
            accelerometerDataCount = 0	// reset for the next round
            
            // Calculating the variance of the Euclidian Norm of the accelerometer data
            let accelerationMean = (totalAcceleration / 10).roundTo(precision: roundingPrecision)
            var total: Double = 0.0
            
            for data in accelerometerDataInASecond {
                total += ((data-accelerationMean) * (data-accelerationMean)).roundTo(precision: roundingPrecision)
            }
            
            total = total.roundTo(precision: roundingPrecision)
            
            let result = (total / 10).roundTo(precision: roundingPrecision)
            print("**** Result: \(result) ****")
            
            if (result < staticThreshold) {
                print("Static")
                
            } else if ((staticThreshold <= result) && (result <= slowWalkingThreshold)) {
                print("Slow Walking")
                
            } else if (slowWalkingThreshold < result) {
                print("Fast Walking")
            }
            
            // reset for the next round
            accelerometerDataInASecond = []
            totalAcceleration = 0.0
            
            if startResult == nil
            {
                startResult = result  // grab the first (starting result)
                startTime =  NSDate() // grab the first time
                return
            }
            
            endResult = result
            
            let now = NSDate()
            let theInterval = now.timeIntervalSince(startTime as Date) // get time passed
            
            // now time it
            if theInterval >= 2.5
            {
                if startResult == nil || endResult == nil
                {
                    return // don't have both results so exit
                }
                
                let diff = endResult! - startResult!
                print("diff = \(diff)")
                
                
                if diff < -staticThreshold  // diff < 0
                {
                    delegate?.brakeLightStatusChanged(isBrakeOn: true)
                }
                else
                {
                    delegate?.brakeLightStatusChanged(isBrakeOn: false)
                }
                startResult = nil
            }
            
        }
    }
    
    func startCoreMotionUpdates()
    {
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
        
        // Initiate accelerometer updates
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) -> Void in
            if((error) != nil) {
                print(error!)
            } else {
                self.estimateBrakeStatus(acceleration: (accelerometerData?.acceleration)!)
            }
        }
    }
    
    func stopCoreMotionUpdates() { motionManager.stopAccelerometerUpdates() }
    
}

/*  Raw Accelerometer Data = effects of gravity + effects of device motion
	Applying a low-pass filter to the raw accelerometer data in order to keep only
	the gravity component of the accelerometer data.
	If it was a high-pass filter, we would've kept the device motion component.
	SOURCES
 http://litech.diandian.com/post/2012-10-12/40040708346
 https://gist.github.com/kristopherjohnson/0b0442c9b261f44cf19a
 */
extension Double {
    func lowPassFilter(filterFactor: Double, previousValue: Double) -> Double {
        return (previousValue * filterFactor/100) + (self * (1 - filterFactor/100))
    }
}


extension Double {
     func roundTo(precision: Int) -> Double {
        let divisor = pow(10.0, Double(precision))
        return Darwin.round(self * divisor) / divisor
    }
 
}

