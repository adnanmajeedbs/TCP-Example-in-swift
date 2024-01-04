//
//  ViewController.swift
//  TCPConnectionExample
//
//  Created by Adnan Majeed on 31/05/2021.
//

import UIKit

class ViewController: UIViewController, AppSocketDelegate {
    func didConnected(Connected: Bool) {
        print("Connected:" ,Connected)
    }
    
    func didsent(Connected: Bool) {
        print("didsent:" ,Connected)
    }
    
    func RecievedData(data: Data) {
        DispatchQueue.main.async {
            if  self.FirstIV.image == nil {
                self.FirstIV.image = UIImage(data: data)
            }
            else if self.SecondIV.image == nil {
                self.SecondIV.image = UIImage(data: data)
            }
            else if self.ThirdtIV.image == nil {
                self.ThirdtIV.image = UIImage(data: data)
            }
        }
    }
    
    @IBOutlet weak var FirstIV: UIImageView!
    @IBOutlet weak var SecondIV: UIImageView!
    @IBOutlet weak var ThirdtIV: UIImageView!
    @IBOutlet weak var FirstIVprogressLbl: UILabel!
    @IBOutlet weak var SecondIVprogressLbl: UILabel!
    @IBOutlet weak var lblIP: UILabel!
    @IBOutlet weak var ThirdtIVprogressLbl: UILabel!
    @IBOutlet weak var FirstIVprogressBar: UIProgressView!
    @IBOutlet weak var SecondIVprogressBar: UIProgressView!
    @IBOutlet weak var ThirdtIVprogressBar: UIProgressView!
    
    @IBOutlet weak var btnDownload: UIButton!
    var objVM:ViewModel!
    var isSever:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Client.shared.ConnectionDelegate = self
        Server.shared.delegate = self
        FirstIVprogressBar.progress = 0
        SecondIVprogressBar.progress = 0
        ThirdtIVprogressBar.progress = 0
        objVM = ViewModel(context: self)
        objVM.delegate = self
        self.lblIP.text = "IP: " + UIDevice.current.IP()
        Server.shared.delegate = self
        
        Client.shared.ConnectionDelegate = self
        
        
        // Do any additional setup after loading the view.
    }
    @IBAction func btnActionDownloadImage(_ sender: UIButton) {
        
        
        FirstIVprogressBar.isHidden = false
        SecondIVprogressBar.isHidden =  false
        ThirdtIVprogressBar.isHidden =  false
        FirstIVprogressLbl.isHidden = false
        SecondIVprogressLbl.isHidden =  false
        ThirdtIVprogressLbl.isHidden =  false
        FirstIVprogressLbl.text = "0"
        SecondIVprogressLbl.text = "0"
        ThirdtIVprogressLbl.text = "0"
        self.objVM.startDownload()
        
        
        
        
    }
}

extension ViewController:ViewModelDelegate{
    func didDownload(tagId: Int, img: UIImage) {
        
        Server.shared.sendData(data:img.jpegData(compressionQuality: 0.5)! )
        DispatchQueue.main.async {
            [weak self] in
            if tagId == 1 {
                self?.FirstIV.image = img
                self?.FirstIVprogressBar.isHidden = true
                self?.FirstIVprogressLbl.isHidden = true
                self?.FirstIVprogressLbl.text = "0"
                
            }
            else if tagId == 2{
                self?.SecondIV.image = img
                self?.SecondIVprogressBar.isHidden = true
                self?.SecondIVprogressLbl.isHidden =  true
                self?.SecondIVprogressLbl.text = "0"
                
            }
            else {
                self?.ThirdtIV.image = img
                self?.ThirdtIVprogressBar.isHidden = true
                self?.ThirdtIVprogressLbl.isHidden =  true
                self?.ThirdtIVprogressLbl.text = "0"
            }
        }
    }
    
    func didChangeProgress(tagId: Int, pregress: Float) {
        DispatchQueue.main.async {
            [weak self] in
            
            if tagId == 1 {
                self?.FirstIVprogressBar.progress = pregress
                self?.FirstIVprogressLbl.text = String("\(Int(pregress * 100))%")
            }
            else if tagId == 2{
                self?.SecondIVprogressBar.progress = pregress
                self?.SecondIVprogressLbl.text = String("\(Int(pregress * 100))%")
            }
            else {
                self?.ThirdtIVprogressBar.progress = pregress
                self?.ThirdtIVprogressLbl.text = String("\(Int(pregress * 100))%")
            }
        }
        
    }
    
    
}
