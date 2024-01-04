//
//  ViewModel.swift
//  TCPConnectionExample
//
//  Created by Adnan Majeed on 31/05/2021.
//

import UIKit



protocol ViewModelDelegate {
    func didDownload(tagId:Int,img:UIImage)
    func didChangeProgress(tagId:Int,pregress:Float)
    
}

class ViewModel: NSObject {
    var context:UIViewController!
    var ImagesPath:[ImagePathModel] = []
    var delegate:ViewModelDelegate!
  
    init(context:UIViewController) {
        super.init()
        self.context = context
        ImagesPath = [
            ImagePathModel(id: 1, name: "airplane", filePath: "https://homepages.cae.wisc.edu/~ece533/images/airplane.png"),
            ImagePathModel(id: 2, name: "baboon", filePath: "https://homepages.cae.wisc.edu/~ece533/images/baboon.png"),
            ImagePathModel(id: 3, name: "arctichare", filePath: "https://homepages.cae.wisc.edu/~ece533/images/arctichare.png")
        ]
       
    }
    func startDownload(){
      
            for path in ImagesPath   {
                guard let url = URL(string: path.filePath) else {
                    print("This is an invalid URL")
                    return
                }
                
                let defaultconfig = URLSession.shared.configuration
                let session = URLSession(configuration:defaultconfig, delegate: self, delegateQueue: nil)
                session.downloadTask(with: url).resume()
            }
        }
    
}

extension ViewModel: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        /// this just only for three time for custom requirement if these are generic then should be generic logic
        guard let data = try? Data(contentsOf: location) else {
            print("The data could not be loaded")
            return
        }
       
       let img =  self.ImagesPath.first(where: {
                $0.filePath == (downloadTask.currentRequest?.url?.absoluteString ?? "")
            })
            img?.ImageData = data
            img?.DownloadImage = UIImage(data: data)
            self.delegate.didDownload(tagId: img?.id ?? 0, img:  UIImage(data: data)!)
      
    
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
            let img =  self.ImagesPath.first(where: {
                $0.filePath == (downloadTask.currentRequest?.url?.absoluteString ?? "")
                })
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.delegate.didChangeProgress(tagId: img?.id ?? 0, pregress: progress)
        
        
        
        
    }
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
   
        print(error?.localizedDescription)
    }
   
}
