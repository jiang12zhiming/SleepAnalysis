//
//  MotionDataSet+CoreDataProperties.swift
//  motionAware
//
//  Created by ZL J on 17/1/8.
//  Copyright © 2017年 ZL J. All rights reserved.
//

import Foundation
import CoreData


extension MotionDataSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MotionDataSet> {
        return NSFetchRequest<MotionDataSet>(entityName: "MotionDataSet");
    }

    @NSManaged public var accX: Double
    @NSManaged public var accY: Double
    @NSManaged public var accZ: Double
    @NSManaged public var rotX: Double
    @NSManaged public var rotY: Double
    @NSManaged public var rotZ: Double
    @NSManaged public var attRoll: Double
    @NSManaged public var attPitch: Double
    @NSManaged public var attYaw: Double
    @NSManaged public var gravX: Double
    @NSManaged public var gravY: Double
    @NSManaged public var gravZ: Double
    @NSManaged public var timeStamp: NSDate?

}
