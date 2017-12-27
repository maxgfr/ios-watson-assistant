//
//  LoginViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 25/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit
import SwiftCloudant
import CryptoSwift
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any-resources that can be recreated.
    }
    
    @IBAction func onAdd(_ sender: Any) {
        let username = loginTextField.text;
        let userPassword = passwordTextField.text;
    
        // Check for empty fields
        if((username?.isEmpty)! || (userPassword?.isEmpty)!){
            // Display alert message
            displayMyAlertMessage(userMessage: "All fields are required", type:"Alert")
            return
        }
        
        // Create a CouchDBClient
        let cloudantURL = NSURL(string:Credentials.CloudantUrl)!
        let client = CouchDBClient(url:cloudantURL as URL, username:Credentials.CloudantUsername, password:Credentials.CloudantPassword)
        let dbName = Credentials.CloudantName
        // Hash password
        let hash = userPassword?.sha1()
        //Verification
        var bool = false;
        //Synchronisation
        let myGroup = DispatchGroup()
        //To Store in local
        let defaults = UserDefaults.standard
        
        //Let's wait
        myGroup.enter()
        
        // Find a document
        let create = FindDocumentsOperation(selector: ["username": username!, "password": hash!], databaseName: dbName) {(response, httpInfo, error) in
            print(JSON(response!))
            let json = JSON(response!)
            if (json["bookmark"].stringValue != "nil") {
                print("Success")
                bool = true
            } else {
                print("Echec")
                bool = false
            }
            //Finish to wait
            myGroup.leave()
        }
        client.add(operation:create)
        
        myGroup.notify(queue: .main) {
            print("Finished all requests.")
            if (bool) {
                let refreshAlert = UIAlertController(title: "Congratulation", message: "Your are  now connected.", preferredStyle: UIAlertControllerStyle.alert)
                refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                    self.dismiss(animated: true, completion:nil)
                }))
                defaults.set(username!, forKey: "Identifiant")
                self.present(refreshAlert, animated: true, completion: nil)
            } else {
                self.displayMyAlertMessage(userMessage: "Your username or password are incorrect.", type:"Alert")
            }
        }
       
        return
    }
    
    func displayMyAlertMessage(userMessage:String, type:String){
        let myAlert = UIAlertController(title:type, message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
    }
    
    
}
