//
//  ExportCSVFile.swift
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


// **************** Export CSV File **************** //
func storeTranscription() {
    let context = DataAccessControllerWatch.getContext()
    
    //retrieve the entity that we just created
    let entity =  NSEntityDescription.entity(forEntityName: "MotionDataSet", in: context)
    let entityHeartRate = NSEntityDescription.entity(forEntityName: "HealthDataSet", in: context)
    
    let transc = NSManagedObject(entity: entity!, insertInto: context) as! MotionDataSet
    let transcHeartRate = NSManagedObject(entity: entityHeartRate!, insertInto: context) as! HealthDataSet
    
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
    transc.timeStamp = UInt64(timeStamp)
    transc.heartRate = heartRate
    transcHeartRate.timeStamp = Int64(UInt64(timeStamp))
    transcHeartRate.heartRate = heartRate
    
    
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
    let fetchRequestHeartRate: NSFetchRequest<HealthDataSet> = HealthDataSet.fetchRequest()
    do {
        //go get the results
        let searchResults = try DataAccessControllerWatch.getContext().fetch(fetchRequest)
        fetchedStatsArray = searchResults as [NSManagedObject]
        //I like to check the size of the returned results!
        print ("num of results = \(searchResults.count)")
        //You need to convert to NSManagedObject to use 'for' loops
        //            for trans in searchResults as [NSManagedObject] {
        //                //get the Key Value pairs (although there may be a better way to do that...
        //                print("\(trans.value(forKey: "accX")!)")
        ////                let mdate = trans.value(forKey: "timeStamp") as! Date
        ////                print(mdate)
        //            }
        //
    } catch {
        print("Error with request: \(error)")
    }
    
    do {
        //go get the results
        let searchResultsHealthData = try DataAccessControllerWatch.getContext().fetch(fetchRequestHeartRate)
        fetchedStatsArrayHeartRate = searchResultsHealthData as [NSManagedObject]
        
        //I like to check the size of the returned results!
        print ("num of results = \(searchResultsHealthData.count)")
        //You need to convert to NSManagedObject to use 'for' loops
        //            for trans in searchResults as [NSManagedObject] {
        //                //get the Key Value pairs (although there may be a better way to do that...
        //                print("\(trans.value(forKey: "accX")!)")
        ////                let mdate = trans.value(forKey: "timeStamp") as! Date
        ////                print(mdate)
        //            }
        //
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
    var rotAxisXVar: NSNumber?
    var rotAxisYVar: NSNumber?
    var rotAxisZVar: NSNumber?
    var gravAxisXVar: NSNumber?
    var gravAxisYVar: NSNumber?
    var gravAxisZVar: NSNumber?
    var attAxisRollVar: NSNumber?
    var attAxisPitchVar: NSNumber?
    var attAxisYawVar: NSNumber?
    var timeStampVarMotionData: NSNumber?
    var heartRateVar: NSNumber?
    var timeStampVarHeartRate: NSNumber?
    
    
    var export = NSLocalizedString("timeStamp, accX, accY, accZ, rotX, rotY, rotZ, gravX, gravY, gravZ, attRoll, attPitch, attYaw,\n", comment: "")
    
    for (index, MotionDataSet) in fetchedStatsArray.enumerated()  {
        if index <= fetchedStatsArray.count - 1 {
            accAxisXVar = MotionDataSet.value(forKey: "accX") as! NSNumber?
            accAxisYVar = MotionDataSet.value(forKey: "accY") as! NSNumber?
            accAxisZVar = MotionDataSet.value(forKey: "accZ") as! NSNumber?
            rotAxisXVar = MotionDataSet.value(forKey: "rotX") as! NSNumber?
            rotAxisYVar = MotionDataSet.value(forKey: "rotY") as! NSNumber?
            rotAxisZVar = MotionDataSet.value(forKey: "rotZ") as! NSNumber?
            gravAxisXVar = MotionDataSet.value(forKey: "gravX") as! NSNumber?
            gravAxisYVar = MotionDataSet.value(forKey: "gravY") as! NSNumber?
            gravAxisZVar = MotionDataSet.value(forKey: "gravZ") as! NSNumber?
            attAxisRollVar = MotionDataSet.value(forKey: "attRoll") as! NSNumber?
            attAxisPitchVar = MotionDataSet.value(forKey: "attPitch") as! NSNumber?
            attAxisYawVar = MotionDataSet.value(forKey: "attYaw") as! NSNumber?
            timeStampVarMotionData = MotionDataSet.value(forKey: "timeStamp") as! NSNumber?
            //heartRateVar = MotionDataSet.value(forKey: "heartRate") as! NSNumber?
            //timeStampVarHeartRate = MotionDataSet.value(forKey: "timeStampHeartRate") as! NSNumber?
            
            let accAxisXString = accAxisXVar
            let accAxisYString = accAxisYVar
            let accAxisZString = accAxisZVar
            let rotAxisXString = rotAxisXVar
            let rotAxisYString = rotAxisYVar
            let rotAxisZString = rotAxisZVar
            let gravAxisXString = gravAxisXVar
            let gravAxisYString = gravAxisYVar
            let gravAxisZString = gravAxisZVar
            let attAxisRollString = attAxisRollVar
            let attAxisPitchString = attAxisPitchVar
            let attAxisYawString = attAxisYawVar
            let timeStampString = timeStampVarMotionData
            //let heartRateString = heartRateVar
            //let timeStampHeartRateString = timeStampVarHeartRate
            
            export += "\(timeStampString!),\(accAxisXString!),\(accAxisYString!),\(accAxisZString!),\(rotAxisXString!),\(rotAxisYString!),\(rotAxisZString!),\(gravAxisXString!),\(gravAxisYString!),\(gravAxisZString!),\(attAxisRollString!),\(attAxisPitchString!),\(attAxisYawString!) \n"
        }
        
    }
    for (i, HealthDataSet) in fetchedStatsArrayHeartRate.enumerated() {
        
        if i <= fetchedStatsArrayHeartRate.count - 1 {
            heartRateVar = (HealthDataSet.value(forKey: "heartRate") as! NSNumber?)
            timeStampVarHeartRate = (HealthDataSet.value(forKey: "timeStamp") as! NSNumber?)
            
            let heartRateString = heartRateVar
            let timeStampStringHeartRateString = timeStampVarHeartRate
            export.insert(contentsOf: "\(heartRateString!), ".characters, at: export.index(before: export.endIndex))
            export.insert(contentsOf: "\(timeStampStringHeartRateString!)\n ".characters, at: export.index(before: export.endIndex))
            //                export += "\(heartRateString!), \(timeStampStringHeartRateString!) \n"
            //                print(i, timeStampVarHeartRate!, heartRateVar!, "\n")
            //
            //print(timeStampVarHeartRate!, "\n")
            //heartRateVar = HealthDataSet.value(forKey: <#T##String#>)
            //print(heartRateVar!, "\n")
            
            
        }
    }
    print("This is what the app will export: \(export)")
    return export
}



//    func createExportStringHeartRate() -> String {
//
//
//        var heartRateVar: NSNumber?
//        var timeStampVarHeartRate: NSNumber?
//
//
//        var export: String = NSLocalizedString("heartRateTimeStamp, heartRate \n", comment: "")
//        for (index, HealthDataSet) in fetchedStatsArray.enumerated() {
//            if index <= fetchedStatsArray.count - 1 {
//                heartRateVar = (HealthDataSet.value(forKey: "heartRate") as! NSNumber?)
//                timeStampVarHeartRate = (HealthDataSet.value(forKey: "timeStamp") as! NSNumber?)
//                print(index, timeStampVarHeartRate!, heartRateVar!, "\n")
//                //print(timeStampVarHeartRate!, "\n")
//                //heartRateVar = HealthDataSet.value(forKey: <#T##String#>)
//                //print(heartRateVar!, "\n")
//
//
//            }
//        }
//        //print("This is what the app will export: \(export)")
//        return export
//    }

// **************** End of Export CSV File **************** //
}
