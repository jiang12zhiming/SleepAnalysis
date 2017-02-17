//
//  HealthDataSet+CoreDataProperties.swift
//  motionAware
//
//  Created by ZL J on 17/2/8.
//  Copyright © 2017年 ZL J. All rights reserved.
//

import Foundation
import CoreData


extension HealthDataSet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HealthDataSet> {
        return NSFetchRequest<HealthDataSet>(entityName: "HealthDataSet");
    }

    @NSManaged public var heartRate: Double
    @NSManaged public var timeStamp: Int64

}
