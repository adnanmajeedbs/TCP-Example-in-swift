//
//  ImagePathModel.swift
//  TCPConnectionExample
//
//  Created by Adnan Majeed on 31/05/2021.
//

import Foundation
import UIKit
class ImagePathModel{
    var id:Int!
    var name:String!
    var filePath:String!
    var DownloadImage:UIImage!
    var ImageData:Data!
    init(id:Int, name:String,filePath:String) {
        self.id = id
        self.name = name
        self.filePath = filePath
    }
}
