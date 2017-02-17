//
//  ConnectToPhone.swift
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

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
    }// needed to make WCSessionDelegate work

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
        
    }
}
