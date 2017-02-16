
import UIKit



class DropboxViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DBRestClientDelegate
 {
    
    var dbRestClient: DBRestClient!
    
    
   // let client = DropboxClient(accessToken: "<MY_ACCESS_TOKEN>")
    
    @IBOutlet var bbiConnect: UIBarButtonItem!
    @IBOutlet var tblFiles: UITableView!
    @IBOutlet var progressBar: UIProgressView!
    
    
    var dropboxMetadata: DBMetadata!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleDidLinkNotification(notification:)), name: NSNotification.Name(rawValue: "didLinkToDropboxAccountNotification"), object: nil)
        //#selector(self.handleTap(recognizer:))
        
        
        
        
        tblFiles.delegate = self
        tblFiles.dataSource = self
        
        progressBar.isHidden = true
        
        if DBSession.shared().isLinked() {
            bbiConnect.title = "Disconnect"
            initDropboxRestClient()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func connectToDropbox(_ sender: AnyObject) {
        if !DBSession.shared().isLinked() {
            DBSession.shared().link(from: self)
            
        }
        else {
            DBSession.shared().unlinkAll()
            bbiConnect.title = "Connect"
            dbRestClient = nil
            
        }
    }
    
    
    func handleDidLinkNotification(notification: NSNotification) {
        initDropboxRestClient()
        bbiConnect.title = "Disconnect"
    }
    
    @IBAction func performAction(_ sender: AnyObject) {
        if !DBSession.shared().isLinked() {
            print("You're not connected to Dropbox")
            return
        }
        
        let actionSheet = UIAlertController(title: "Upload file", message: "Select file to upload", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let uploadTextFileAction = UIAlertAction(title: "Upload text file", style: UIAlertActionStyle.default) { (action) -> Void in
            
            
            let uploadFilename = "testtext.txt"
            let sourcePath = Bundle.main.path(forResource: "testtext", ofType: "txt")
            let destinationPath = "/"
            self.showProgressBar()
            self.dbRestClient.uploadFile(uploadFilename, toPath: destinationPath, withParentRev: nil, fromPath: sourcePath)
            
            
            
        }
        
        let uploadImageFileAction = UIAlertAction(title: "Upload image", style: UIAlertActionStyle.default) { (action) -> Void in
            
            
            let uploadFilename = "nature.jpg"
            let sourcePath = Bundle.main.path(forResource: "nature", ofType: "jpg")
            let destinationPath = "/"
            self.showProgressBar()
            
            self.dbRestClient.uploadFile(uploadFilename, toPath: destinationPath, withParentRev: nil, fromPath: sourcePath)
            
            
            
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(uploadTextFileAction)
        actionSheet.addAction(uploadImageFileAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func reloadFiles(_ sender: AnyObject) {
        dbRestClient.loadMetadata("/")
        
    }
    
    
    // MARK: UITableview method implementation
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCellFile", for: indexPath as IndexPath)
        let currentFile: DBMetadata = dropboxMetadata.contents[indexPath.row] as! DBMetadata
        cell.textLabel?.text = currentFile.filename
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let metadata = dropboxMetadata {
            return metadata.contents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func initDropboxRestClient() {
        dbRestClient = DBRestClient(session: DBSession.shared())
        dbRestClient.delegate = self
        dbRestClient.loadMetadata("/")// the “/” means the root folder where the app has access to
        
    }
    
    func restClient(_ client: DBRestClient!, uploadedFile destPath: String!, from srcPath: String!, metadata: DBMetadata!) {
        progressBar.isHidden = true
        
        print("The file has been uploaded.")
        print(metadata.path)
        dbRestClient.loadMetadata("/")
    }
    
    
    func restClient(_ client: DBRestClient!, uploadFileFailedWithError error: Error!) {
        progressBar.isHidden = true
        
        print("File upload failed.")
        print(error)
    }
    
    func restClient(_ client: DBRestClient!, uploadProgress progress: CGFloat, forFile destPath: String!, from srcPath: String!) {
        progressBar.progress = Float(progress)
    }
    
    
    func showProgressBar() {
        progressBar.progress = 0.0
        progressBar.isHidden = false
    }
    
    
    func restClient(_ client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        dropboxMetadata = metadata;
        tblFiles.reloadData()
    }
    func restClient(_ client: DBRestClient!, loadMetadataFailedWithError error: Error!) {
        print(error)
    }
}

