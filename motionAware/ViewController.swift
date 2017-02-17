//
//  ViewController.swift
//  motionAware
//
//  Created by ZL J on 17/1/8.
//  Copyright © 2017年 ZL J. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import WatchConnectivity
import HealthKit
class ViewController: UIViewController, MFMailComposeViewControllerDelegate, WCSessionDelegate{
//
//    @IBOutlet weak var stateValue: UILabel!
    var attachmentFilePath:URL?
    let session = WCSession.default()  // init watch session
    
    @IBOutlet weak var samplingState: UILabel! // Reserved Button
    @IBOutlet weak var samplingRate: UILabel!  // Reserved Button
    @IBOutlet weak var axisXData: UILabel! // Reserved Button
    @IBOutlet weak var axisYData: UILabel!// Reserved Button
    @IBOutlet weak var axisZData: UILabel!// Reserved Button
    let healthStore = HKHealthStore()

    //This part is needed for sensing file between iWatch and iPhone
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    //This part is needed for sensing file between iWatch and iPhone
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard HKHealthStore.isHealthDataAvailable() == true else {
            return
        }
        
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
            if success == false {
            }
        }
        
//        private let session : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
//        
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//            
//            session?.delegate = self
//            session?.activateSession()
//        
        
        if WCSession.isSupported() {
            print(" i get into here ")
            let session = WCSession.default()
            session.delegate = self
            session.activate()
        }
        // Do any additional setup after loading the view, typically from a nib.

        
        
//        let motion : MotionDataSet = NSEntityDescription.insertNewObject(forEntityName: "MotionDataSet", into: DataAccessController.getContext()) as! MotionDataSet
//        
//        
//        motion.accX = 88.8
//        motion.accY = 22.2
//        motion.accZ = 11.1
//        motion.attYaw = 0.1
//        motion.attRoll = 0.2
//        
//        DataAccessController.saveContext()
//
//        
//        
//        let fetchRequest:NSFetchRequest<MotionDataSet> = MotionDataSet.fetchRequest()
//      
//        do{
//            
//            let searchResults = try DataAccessController.getContext().fetch(fetchRequest)
//            
//            print("number of results : \(searchResults.count)")
//            
//            for result in searchResults as [MotionDataSet]{
//                
//                axisXData?.text = "\(result.accX)"
//                axisYData?.text = "\(result.accY)"
//                axisZData?.text = "\(result.accZ)"
//                print("\(result.accX), \(result.accY), \(result.accZ)")
//                
//            }
//        }
//        catch {
//            
//            print("Error: \(error)")
//        }
//         let filePath = myFileString(theFile: attachmentFilePath!)
//         print("File Path is : \(filePath)")

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
// ************ Receive File from iWatch ************ //  // Problem is can not receive the file from iWatch
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        //save in a more permanent location here. file will be deleted after this method is executed
        DispatchQueue.main.async {
            let dirPathc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let docsDir = dirPathc[0] as String
            let fileManager = FileManager.default
            
            print(file.fileURL!.path," <----")
            
            let fullDocsDir = docsDir + "/motiondata.csv"
            if fileManager.fileExists(atPath: fullDocsDir) {
                do {
                    try fileManager.removeItem(atPath: fullDocsDir)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            
            } else {
                print("FILE NOT AVAILABLE --------bala bala ")
                do {
                    try fileManager.moveItem(atPath: file.fileURL!.path, toPath: docsDir + "/motiondata.csv")  // Move file to a known path
                }catch let error as NSError {
                    print("Error Moving File : \(error.description)")
                }
            }
            
            print(file.fileURL!.path," <----after")
            let dict = file.metadata  // Check metadata is successfully transfered
            let name = dict!["sending"]
            self.samplingState?.text = name as! String?
            
        }
        
    }
// ************ End of Receive File from iWatch ************ //

    @IBAction func adjustSamplingRate(_ sender: Any) {
    } // Reserved Button
    
    @IBAction func startAction(_ sender: Any) {
        //let motion : MotionDataSet = NSEntityDescription.insertNewObject(forEntityName: "MotionDataSet", into: DataAccessControllerWatch.getContext()) as! MotionDataSet
        
        
        samplingState?.text = "Start"
        
    }
    
    @IBAction func stopAction(_ sender: Any) {
        samplingState?.text = "Stop"
    }

    @IBAction func exportData(_ sender: Any) {
        samplingState?.text = "Export Data"
    }
    // Butten for attech file and send with email
    
    
    @IBAction func sendEmail(_ sender: Any) {
        
        let filename = "motiondata.csv"
        showMailComposerWith(attachmentName: filename)
        fileExistance()
    }

    //*************** Start of mail functions ***************//
    func showMailComposerWith(attachmentName: String){
        
        //let exportFilePath = NSTemporaryDirectory()+"motiondata.csv"
        //let exportFileURL = NSURL(fileURLWithPath: exportFilePath)
        //let filePath = attachmentFilePath?.path // Convert URL to FilaPath
        
        fileExistance()
        
        let dirPathc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPathc[0] as String
        let filePath = docsDir + "/motiondata.csv"
        
        print("\n Atteched File Path is: \(filePath)\n")
        
        if MFMailComposeViewController.canSendMail(){
            
            let subject = "send succeffuly"
            let messageBody = "Atteched CSV file"
            let toRecipients = ["zljin85@163.com"]
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject(subject)
            mailComposer.setMessageBody(messageBody, isHTML: false)
            mailComposer.setToRecipients(toRecipients)
            
            let fileParts = attachmentName.components(separatedBy: ".")
            let fileName = fileParts[0]
            let fileExtension = fileParts[1]
            
            do{
                try mailComposer.addAttachmentData(NSData(contentsOfFile: filePath) as Data, mimeType: fileExtension, fileName: "\(fileName).csv")
                self.present(mailComposer, animated: true, completion: nil) //presentViewController is replaced by present
                
            }catch {
                
            }
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue{
        case MFMailComposeResult.cancelled.rawValue: break
        case MFMailComposeResult.sent.rawValue: break
        case MFMailComposeResult.saved.rawValue: break
        case MFMailComposeResult.failed.rawValue: break
        default: break
        }
        
        dismiss(animated: true, completion: nil)
    }
//*************** End of mail functions ***************//

    //
    func fileExistance() {
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        let filePath = url.appendingPathComponent("motiondata.csv")?.path
        let dirPathc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPathc[0] as String
        
        let fileManager = FileManager.default
        let filePath = docsDir + "/motiondata.csv"
        if fileManager.fileExists(atPath: filePath) {
            print("File Available")
        } else {
            print("File NOT Available")
        }
        print("Check File Path : \(filePath)")
    }
    
}

