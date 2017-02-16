import Foundation
import CoreData
//import WatchKit

class DataAccessController: NSObject {
    
    class func sharedAppGroup()->String{
    
        return "group.zlj.apptest.motionrecognization"
    }

    class func mangedObjectModel()->NSManagedObjectModel{
    
        let proxyBundle = Bundle(identifier: "zljin.WatchApp")
        
        let modelURL = proxyBundle?.url(forResource: "MotionDataSet", withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }
    
    
    class func persistantStorCoordinator()->NSPersistentStoreCoordinator? {
    
        var error:NSError? = nil
        
        var sharedContainerURL:NSURL? = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataAccessController.sharedAppGroup()) as NSURL?
        if let sharedContainerURL = sharedContainerURL {
            let storeURL = sharedContainerURL.appendingPathComponent("database.sqlite")
            var coordinator:NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: DataAccessController.mangedObjectModel())
            do{
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            }catch {
            
            }
            return coordinator
        }
        return nil
    }
    
    class func managedObjectContext()->NSManagedObjectContext {
        
        let coordinator = DataAccessController.persistantStorCoordinator()
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
    
    class func insertManagedObject(className:NSString, managedObjectContext:NSManagedObjectContext)->AnyObject{
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: className as String, into: managedObjectContext) as! NSManagedObject
        return managedObject
    }
//    class func saveManagedObjectContext(managedObjectContext:NSManagedObjectContext)->Bool {
//        if managedObjectContext.save(nil) {
//            return true
//        }else {
//            return false
//        }
//    
//    }
//    class func fetchEntities (className:NSString, withPredicate predicate:NSPredicate?, andSortDescriptor sortDescriptor:NSSortDescriptor?, managedObjectContext:NSManagedObjectContext)->NSArray{
//    
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
//        let entityDescription = NSEntityDescription.entity(forEntityName: className as String, in: managedObjectContext)
//        
//        fetchRequest.entity = entityDescription
//        if predicate != nil {
//            fetchRequest.predicate = predicate!
//        }
//        if sortDescriptor != nil {
//            fetchRequest.sortDescriptors = [sortDescriptor!]
//        }
//        
//        fetchRequest.returnsObjectsAsFaults = false
//        
//        let items = managedObjectContext.execute(<#T##request: NSPersistentStoreRequest##NSPersistentStoreRequest#>) //managedObjectContext.execute(fetchRequest, error: nil)!
////        do{
////            let items = try managedObjectContext.execute(fetchRequest)
////            
////        }catch {
////        }
//        return items
//    }
    
    
    
    
    // MARK: - Core Data stack
    private override init() {
        
    }
    
    class func getContext() -> NSManagedObjectContext {
        
        return DataAccessController.persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "motionAware")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        //container.persistentStoreCoordinator
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        let context = DataAccessController.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    //    public class func deletRecords() -> Void {
    //
    //        let moc = self.getContext()
    //        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "MotionDatasSet")
    //
    //        let result = try? moc.fetch(fetchRequest)
    //        let resultData = result as! [MotionDataSet]
    //
    //        for object in resultData {
    //
    //            moc.delete(object)
    //        }
    //        do {
    //
    //            try moc.save()
    //            print("Saved!")
    //        }catch let error as NSError {
    //
    //            print("error")
    //        }
    //        
    //        
    //    }
    
    
}
