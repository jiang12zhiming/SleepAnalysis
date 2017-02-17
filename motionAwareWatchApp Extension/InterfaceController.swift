//
//  InterfaceController.swift
//  motionAwareWatchApp Extension
//
//  Created by ZL J on 17/1/8.
//  Copyright © 2017年 ZL J. All rights reserved.
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


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    

    var accAxisX: Double = 0.0
    var accAxisY: Double = 0.0
    var accAxisZ: Double = 0.0
    var rotAxisX: Double = 0.0
    var rotAxisY: Double = 0.0
    var rotAxisZ: Double = 0.0
    var gravAxisX: Double = 0.0
    var gravAxisY: Double = 0.0
    var gravAxisZ: Double = 0.0
    var attAxisRoll: Double = 0.0
    var attAxisPitch: Double = 0.0
    var attAxisYaw: Double = 0.0
    var timeStamp: Double = 0.0
    var heartRate: Double = 0.0
    
    var fetchedStatsArray: [NSManagedObject] = []
    var fetchedStatsArrayHeartRate: [NSManagedObject] = []
    
    @IBOutlet var heartRatelabel: WKInterfaceLabel!
    var watchMotionManager = CMMotionManager()
    
    let session = WCSession.default()  // init session
    var workoutActive = false
    var workoutSessionVar : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    var currenQuery : HKQuery?
    let healthStore = HKHealthStore()
    

    
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        
//    }// needed to make WCSessionDelegate work
//    
    @IBOutlet var samplingState: WKInterfaceLabel!
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.setupWatchConnect()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        guard HKHealthStore.isHealthDataAvailable() == true else {
            heartRatelabel.setText("not available")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            displayNotAllowed()
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
                self.displayNotAllowed()
            }
        }
        
                let fetchRequest:NSFetchRequest<HealthDataSet> = HealthDataSet.fetchRequest()
        
                do{
        
                    let searchResults = try DataAccessControllerWatch.getContext().fetch(fetchRequest)
        
                    print("number of results : \(searchResults.count)")
        
                    for result in searchResults as [HealthDataSet]{
        
                        print("\(result.timeStamp), \(result.heartRate)")
        
                    }
                }
                catch {
                    
                    print("Error: \(error)")
                }
        
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
//    
//    
//    func setupWatchConnect(){
//        self.setupWatchConnectivity()  // Create Watch Connection
//        
//        let fetchRequest:NSFetchRequest<MotionDataSet> = MotionDataSet.fetchRequest()
//        do{
//            let searchResults = try DataAccessControllerWatch.getContext().fetch(fetchRequest)  // Get the data in CoreData
//            print("number of results : \(searchResults.count)")
//            for result in searchResults as [MotionDataSet]{
//                print("\(result.accX), \(result.accY), \(result.accZ)")
//            }
//        }
//        catch {
//            print("Error: \(error)")
//        }
//
//    }

    
    
    
    
    @IBAction func startMotionDataSampling() {
        deletRecords()
        
        if(self.workoutActive == false) {
            //start a new workout
            self.workoutActive = true
            startWorkout()
        }
        

        
       watchMotionManager.deviceMotionUpdateInterval = 1/50 // Sampling Rate
        
        if watchMotionManager.isDeviceMotionAvailable{  // Device motion
            
            watchMotionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (deviceManager: CMDeviceMotion?, error) in
                self.outputWatchMotionData(watchMotion: deviceManager!)  //Start updata Gyro data
                if (error != nil){
                    
                    print("Error!")
                }
            })
            
        }else {
            
            samplingState?.setText("Rotation is not available")
        }
    }
    
    @IBAction func stopMotionDataSampling() {
        if (self.workoutActive) {
            //finish the current workout
            self.workoutActive = false
            if let workout = self.workoutSessionVar {
                healthStore.end(workout)
            }
        }
        
        DataAccessControllerWatch.saveContext()  // Save the collected data to CoreData
        
        if watchMotionManager.isDeviceMotionActive {
            
            watchMotionManager.stopDeviceMotionUpdates()  // Stop device motion
        }
        
        samplingState?.setText("Stop")
    }
    
    
    @IBAction func exportDataToFile() {
        storeTranscription()
        getTranscriptions()
        
        exportDatabase()  //Export data to CVS files

        fileExistance()  // Check file Existance
        //deletRecords()
    }

    @IBAction func SendFileToMainApp() { // Send file to iphone app
        if session.isReachable == true {
            print("Connection Created")
        }
        let exportFilePath = NSTemporaryDirectory() + "motiondata.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        let metadata = ["sending":"Success"]
        session.transferFile(exportFileURL as URL, metadata: metadata)  // Send File to iPhone App
        print("\n File URL is: \(exportFileURL)")
        print("\n File Path is: \(exportFileURL.path)")
    }
    
    
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if self.session.isReachable {
            self.setupWatchConnectivity()
        }
    }

    func setupWatchConnectivity() {
        self.session.delegate = self
        self.session.activate()
    }
    
    func fileExistance() {
        let exportFilePath = NSTemporaryDirectory()
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        let filePath = exportFileURL.appendingPathComponent("motiondata.csv")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!) {
            print("File Available")
        } else {
            print("File NOT Available")
        }
        print("Check file path is: \(filePath)")
        print("Check file URL is: \(exportFileURL.appendingPathComponent("motiondata.csv"))")


    }


    
}
