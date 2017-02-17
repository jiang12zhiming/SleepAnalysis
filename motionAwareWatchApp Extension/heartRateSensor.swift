//
//  heartRateSensor.swift
//  motionAware
//
//  Created by Zhiming Jiang on 2/7/17.
//  Copyright © 2017 ZL J. All rights reserved.
//

import HealthKit
import CoreData
import DataAccessWatch

extension InterfaceController: HKWorkoutSessionDelegate {

//
//    @IBOutlet private weak var deviceLabel : WKInterfaceLabel!
//    @IBOutlet private weak var heart: WKInterfaceImage!
//    @IBOutlet private weak var startStopButton : WKInterfaceButton!
//    
//
    
    func displayNotAllowed() {
        heartRatelabel.setText("not allowed")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            workoutDidStart(date)
        case .ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)")
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        // Do nothing for now
        print("Workout error")
    }
    
    
    func workoutDidStart(_ date : Date) {
        if let query = createHeartRateStreamingQuery(date) {
            self.currenQuery = query
            healthStore.execute(query)
        } else {
            heartRatelabel.setText("cannot start")
        }
    }
    
    func workoutDidEnd(_ date : Date) {
        healthStore.stop(self.currenQuery!)
        heartRatelabel.setText("---")
        workoutSessionVar = nil
    }
    
    // MARK: - Actions

    
    func startWorkout() {
        
        // If we have already started the workout, then do nothing.
        if (workoutSessionVar != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .crossTraining
        workoutConfiguration.locationType = .indoor
        
        do {
            workoutSessionVar = try HKWorkoutSession(configuration: workoutConfiguration)
            workoutSessionVar?.delegate = self
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        healthStore.start(self.workoutSessionVar!)
    }
    
    func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
        
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
        //let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
        
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            //guard let newAnchor = newAnchor else {return}
            //self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            //self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(_ samples: [HKSample]?) {
        let healthData : HealthDataSet = NSEntityDescription.insertNewObject(forEntityName: "HealthDataSet", into: DataAccessControllerWatch.getContext()) as! HealthDataSet

        
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
        
        DispatchQueue.main.async {
            guard let sample = heartRateSamples.first else{return}
            let value = sample.quantity.doubleValue(for: self.heartRateUnit)
            self.heartRatelabel.setText(String(UInt16(value)))
            print(value,"  <----show me lable")
            // retrieve source from sample
            _ = sample.sourceRevision.source.name
            //self.updateDeviceName(name)
            //self.animateHeart()
            healthData.heartRate = value
            healthData.timeStamp = UInt64(Date().timeIntervalSince1970 * 1000)
            print(healthData.heartRate, "<------in CoreData")
        }
    }

    



}
