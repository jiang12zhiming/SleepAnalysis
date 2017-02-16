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
    var timeStampVar: NSDate? = NSDate()
    var fetchedStatsArray: [NSManagedObject] = []
    
    @IBOutlet var heartRatelabel: WKInterfaceLabel!
    var watchMotionManager = CMMotionManager()
    
    let session = WCSession.default()  // init session
    var workoutActive = false
    var workoutSessionVar : HKWorkoutSession?
    let heartRateUnit = HKUnit(from: "count/min")
    var currenQuery : HKQuery?
    let healthStore = HKHealthStore()

    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }// needed to make WCSessionDelegate work
    
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

        
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    func setupWatchConnect(){
        self.setupWatchConnectivity()  // Create Watch Connection
        
        let fetchRequest:NSFetchRequest<MotionDataSet> = MotionDataSet.fetchRequest()
        do{
            let searchResults = try DataAccessControllerWatch.getContext().fetch(fetchRequest)  // Get the data in CoreData
            print("number of results : \(searchResults.count)")
            for result in searchResults as [MotionDataSet]{
                print("\(result.accX), \(result.accY), \(result.accZ)")
            }
        }
        catch {
            print("Error: \(error)")
        }
        storeTranscription()
        getTranscriptions()
    }


    @IBAction func startMotionDataSampling() {
        if(self.workoutActive == false) {
            //start a new workout
            self.workoutActive = true
            startWorkout()
        }
        
        watchMotionManager.accelerometerUpdateInterval = 0.3  // Sampling Rate
        watchMotionManager.gyroUpdateInterval = 0.3  // Sampling Rate
        
        if watchMotionManager.isAccelerometerAvailable{
        
            watchMotionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (watchAccelerometerData, error) in
                self.outputWatchAcceleationData(watchAcceleration: (watchAccelerometerData?.acceleration)!)  //Start updata Accelerometer data
                //print("x: \(accelerometerData?.acceleration.x)", "y: \(accelerometerData?.acceleration.y)", "z: \(accelerometerData?.acceleration.z)")
                if (error != nil){
                    
                    print("Error!")
                }
                
            })
            
        } else {
        
            samplingState?.setText("Accelermeter is not available")
        }
        
        if watchMotionManager.isGyroAvailable{  // Rotation is not available
        
            watchMotionManager.startGyroUpdates(to: OperationQueue.current!, withHandler: { (watchGyroData, error) in
                self.outputWatchRotationData(watchRotation: (watchGyroData?.rotationRate)!)  //Start updata Gyro data
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
        
        if watchMotionManager.isAccelerometerActive {
            
            watchMotionManager.stopAccelerometerUpdates()  // Stop ACC
        }
        if watchMotionManager.isGyroActive {
            
            watchMotionManager.stopGyroUpdates()  // Stop Gyro
        }
        
        samplingState?.setText("Stop")
    }
    
    
    @IBAction func exportDataToFile() {
        exportDatabase()  //Export data to CVS files

        fileExistance()  // Check file Existance
    }

    @IBAction func SendFileToMainApp() { // Send file to iphone app
        if session.isReachable == true {
            print("Connection Created")
        }
        let exportFilePath = NSTemporaryDirectory() + "motiondata.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        let metadata = ["sending":"Grio"]
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
        
        
    }
// **************** Read Motion Data to CoreData **************** //
    func outputWatchAcceleationData(watchAcceleration:CMAcceleration){
        
        let motionData : MotionDataSet = NSEntityDescription.insertNewObject(forEntityName: "MotionDataSet", into: DataAccessControllerWatch.getContext()) as! MotionDataSet
        
        motionData.accX = watchAcceleration.x
        motionData.accY = watchAcceleration.y
        motionData.accZ = watchAcceleration.z
        
    }
    
    func outputWatchRotationData(watchRotation:CMRotationRate){
        
        let motionData : MotionDataSet = NSEntityDescription.insertNewObject(forEntityName: "MotionDataSet", into: DataAccessControllerWatch.getContext()) as! MotionDataSet
        
        motionData.rotX = watchRotation.x
        motionData.rotY = watchRotation.y
        motionData.rotZ = watchRotation.z
    }
// **************** End of Read Motion Data to CoreData **************** //

// **************** Export CSV File **************** //
    func storeTranscription() {
        let context = DataAccessControllerWatch.getContext()
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "MotionDataSet", in: context)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context) as! MotionDataSet
        
        //set the entity values
        transc.accX = accAxisX
        transc.accY = accAxisY
        transc.accZ = accAxisZ
        transc.rotX = rotAxisX
        transc.rotY = rotAxisY
        transc.rotZ = rotAxisZ
        transc.gravX = gravAxisX
        transc.gravY = gravAxisY
        transc.gravZ = gravAxisZ
        transc.attRoll = attAxisRoll
        transc.attPitch = attAxisPitch
        transc.attYaw = attAxisYaw
        transc.timeStamp = timeStampVar
        
        
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    func getTranscriptions () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<MotionDataSet> = MotionDataSet.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try DataAccessControllerWatch.getContext().fetch(fetchRequest)
            fetchedStatsArray = searchResults as [NSManagedObject]
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(trans.value(forKey: "accX")!)")
//                let mdate = trans.value(forKey: "timeStamp") as! Date
//                print(mdate)
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func exportDatabase() {
        let exportString = createExportString()
        saveAndExport(exportString: exportString)
    }
    
    func saveAndExport(exportString: String) {
        let exportFilePath = NSTemporaryDirectory() + "motiondata.csv"
        let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        //let filepath = exportFileURL.path
        FileManager.default.createFile(atPath: exportFilePath, contents: NSData() as Data, attributes: nil)
        //var fileHandleError: NSError? = nil
        var fileHandle: FileHandle? = nil
        do {
            fileHandle = try FileHandle(forWritingTo: exportFileURL as URL)
        } catch {
            print("Error with fileHandle")
        }
        
        if fileHandle != nil {
            fileHandle!.seekToEndOfFile()
            let csvData = exportString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            fileHandle!.write(csvData!)
            
            fileHandle!.closeFile()
            
            //            let firstActivityItem = NSURL(fileURLWithPath: exportFilePath)
            //            let activityViewController : UIActivityViewController = UIActivityViewController(
            //                activityItems: [firstActivityItem], applicationActivities: nil)
            //
            //            activityViewController.excludedActivityTypes = [
            //                UIActivityType.assignToContact,
            //                UIActivityType.saveToCameraRoll,
            //                UIActivityType.postToFlickr,
            //                UIActivityType.postToVimeo,
            //                UIActivityType.postToTencentWeibo
            //            ]
            //
            //            self.present(activityViewController, animated: true, completion: nil)
        }
        
        print("Exported File Path is: \(exportFilePath)\n")
    }
    
    func createExportString() -> String {
        
        var accAxisXVar: NSNumber?
        var accAxisYVar: NSNumber?
        var accAxisZVar: NSNumber?
//        var rotAxisXVar: NSNumber?
//        var rotAxisYVar: NSNumber?
//        var rotAxisZVar: NSNumber?
//        var gravAxisXVar: NSNumber?
//        var gravAxisYVar: NSNumber?
//        var gravAxisZVar: NSNumber?
//        var attAxisRollVar: NSNumber?
//        var attAxisPitchVar: NSNumber?
//        var attAxisYawVar: NSNumber?
        //var timeStampVarVar: NSData? = NSData()
        
        
        var export: String = NSLocalizedString("accX, accY, accZ, timeStamp \n", comment: "")
        for (index, MotionDataSet) in fetchedStatsArray.enumerated()  {
            if index <= fetchedStatsArray.count - 1 {
                accAxisXVar = MotionDataSet.value(forKey: "accX") as! NSNumber?
                accAxisYVar = MotionDataSet.value(forKey: "accY") as! NSNumber?
                accAxisZVar = MotionDataSet.value(forKey: "accZ") as! NSNumber?
                
               //dd let timeStampVarVar = MotionDataSet.value(forKey: "timeStamp") as! Date
                let accAxisXString = accAxisXVar
                let accAxisYString = accAxisYVar
                let accAxisZString = accAxisZVar
                //let timeStampString = "\(timeStampVarVar)"
                export += "\(accAxisXString!),\(accAxisYString!),\(accAxisZString!)\n"
            }
        }
        print("This is what the app will export: \(export)")
        return export
    }
// **************** End of Export CSV File **************** //
    
// **************** Check File Existance **************** //
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
// **************** End of Check File Existance **************** //
}
