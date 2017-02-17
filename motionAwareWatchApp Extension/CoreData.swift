//
//  CoreData.swift
//  motionAware
//
//  Created by Zhiming Jiang on 2/16/17.
//  Copyright © 2017 ZL J. All rights reserved.
//


import WatchKit
import UIKit
import Foundation
import CoreMotion
import CoreData
import DataAccessWatch
import WatchConnectivity
import HealthKit
import WatchKit
extension InterfaceController {

func deletRecords() -> Void {  // Delete the data in CoreData
    
    let moc = DataAccessControllerWatch.getContext()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MotionDataSet")
    
    let result = try? moc.fetch(fetchRequest)
    let resultData = result as! [MotionDataSet]
    
    for object in resultData {
        
        moc.delete(object)
    }
    do {
        
        try moc.save()
        print("Saved!")
    }catch let error as NSError {
        
        print("\(error)")
    }
    
    let mocHealthData = DataAccessControllerWatch.getContext()
    let fetchRequestHealthData = NSFetchRequest<NSFetchRequestResult>(entityName: "HealthDataSet")
    
    let resultHealthData = try? moc.fetch(fetchRequestHealthData)
    let resultDataHealthData = resultHealthData as! [HealthDataSet]
    
    for objectHealthData in resultDataHealthData {
        
        mocHealthData.delete(objectHealthData)
    }
    do {
        
        try mocHealthData.save()
        print("Saved!")
    }catch let errorHealthData as NSError {
        
        print("\(errorHealthData)")
    }
    
    
}
// **************** Read Motion Data to CoreData **************** //
func outputWatchMotionData(watchMotion: CMDeviceMotion){
    
    let motionData : MotionDataSet = NSEntityDescription.insertNewObject(forEntityName: "MotionDataSet", into: DataAccessControllerWatch.getContext()) as! MotionDataSet
    
    motionData.rotX = (watchMotion.rotationRate.x)
    motionData.rotY = (watchMotion.rotationRate.y)
    motionData.rotZ = (watchMotion.rotationRate.z)
    motionData.accX = (watchMotion.userAcceleration.x)
    motionData.accY = (watchMotion.userAcceleration.y)
    motionData.accZ = (watchMotion.userAcceleration.z)
    motionData.attRoll = (watchMotion.attitude.roll)
    motionData.attYaw = (watchMotion.attitude.yaw)
    motionData.attPitch = (watchMotion.attitude.pitch)
    motionData.gravX = (watchMotion.gravity.x)
    motionData.gravY = (watchMotion.gravity.y)
    motionData.gravZ = (watchMotion.gravity.z)
    motionData.timeStamp = UInt64(Date().timeIntervalSince1970 * 1000)  // assign double value so the timestamp should be double
    //print(motionData.accX, motionData.rotX, motionData.gravZ, motionData.attPitch,  "\n")
    
    
}
}
