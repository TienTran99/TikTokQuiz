//
//  ViewController.swift
//  TestDowloadFile
//
//  Created by Valerian on 13/08/2021.
//

import UIKit
import MZDownloadManager

class ViewController: UIViewController {
    
    var availableDownloadsArray: [String] = []
    var myDownloadPath = MZUtility.baseFilePath + "/My Downloads"
    
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let dbRawPath = "https://github.com/TienTran99/TikTokQuiz/blob/main/tiktokquizdbfinal.db?raw=true"
        availableDownloadsArray.append(dbRawPath)
        
        let fileURL  : NSString = availableDownloadsArray[0] as NSString
        var fileName : NSString = fileURL.lastPathComponent as NSString
        fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(fileName as String) as NSString)
        print(fileName)
        downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String, destinationPath: myDownloadPath)
    }
}

extension ViewController: MZDownloadManagerDelegate{
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        print("downloadRequestDidUpdateProgress")
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModel: [MZDownloadModel]) {
        print("downloadRequestDidPopulatedInterruptedTasks")
    }
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
                
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        debugPrint("Error while downloading file: \(String(describing: downloadModel.fileName))  Error: \(String(describing: error))")
    }
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        let myDownloadPath = MZUtility.baseFilePath + "/Default folder"
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(downloadModel.fileName as String) as NSString)
        var path =  myDownloadPath + "/" + (fileName as String)
        path = path.replacingOccurrences(of: "?raw=true", with: "")
        try! FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: path))
        debugPrint("Default folder path: \(myDownloadPath)")
    }
}

