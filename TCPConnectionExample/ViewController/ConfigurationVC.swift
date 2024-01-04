//
//  ConfigurationVC.swift
//  TCPConnectionExample
//
//  Created by Adnan Majeed on 31/05/2021.
//

import UIKit

class ConfigurationVC: UIViewController, AppSocketDelegate {
    func RecievedData(data: Data) {
        print(data)
    }
    
    func didConnected(Connected: Bool) {
        DispatchQueue.main.async {
            if Connected {
                    print("Connected-->",Connected)
                    self.performSegue(withIdentifier: "Showdata", sender: nil)
                    self.ProgressActivity.stopAnimating()
                
            }
            else {
                self.showWarning(title: "Error", message: "Server not connected")
            }
        }
       
    }
    func didsent(Connected: Bool) {
        DispatchQueue.main.async {
            self.ProgressActivity.stopAnimating()
        print("didsent-->",Connected)
        }
    }
    func showWarning(title:String = "Error", message:String = "Please Enter Ip of Server"){
        let Alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let Action = UIAlertAction(title: "OK", style: .cancel, handler: {
            _ in
        })
        Alert.addAction(Action)
        self.present(Alert, animated: true, completion: nil)
    }
   
  
    @IBAction func btnActionConnection(_ sender: UIButton) {
        let textinput = (txtIP.text ?? "" ).trimmingCharacters(in: .whitespacesAndNewlines)
        if textinput.isEmpty {
            showWarning()
        }
        else {
            isSever = false
            
            Client.shared.start(host: textinput, port: UInt16(8080),ConnectionDelegate: self)
            ProgressActivity.isHidden = false
            ProgressActivity.startAnimating()
        }
        
        
    }
    @IBOutlet weak var txtIP: UITextField!
    var isSever:Bool!
    @IBOutlet weak var ProgressActivity: UIActivityIndicatorView!
    @IBAction func StartServer(_ sender: UIButton) {
        isSever = true
      
        ProgressActivity.isHidden = false
        ProgressActivity.startAnimating()
        try?  Server.shared.start(port: UInt16(8080))
//        ServerConnection.shared
      
        self.txtIP.text = "127.0.0.1"
        
//        performSegue(withIdentifier: "Showdata", sender: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressActivity.isHidden = true
        ProgressActivity.stopAnimating()
        Server.shared.delegate = self
        Client.shared.ConnectionDelegate = self
        // Do any additional setup after loading the view.
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       let destination = segue.destination as! ViewController
        
        destination.isSever = isSever
    }
  

}
