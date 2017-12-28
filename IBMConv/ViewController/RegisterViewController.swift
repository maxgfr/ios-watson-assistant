//
//  RegisterViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 21/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit
import SwiftCloudant
import CryptoSwift

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var identifiantTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let userEmail = identifiantTextField.text;
        let userPassword = passwordTextField.text;
        let userRepeatPassword = repeatTextField.text;
        
        // Create a CouchDBClient
        let cloudantURL = NSURL(string:Credentials.CloudantUrl)!
        let client = CouchDBClient(url:cloudantURL as URL, username:Credentials.CloudantUsername, password:Credentials.CloudantPassword)
        let dbName = Credentials.CloudantName
        
        // Check for empty fields
        if((userEmail?.isEmpty)! || (userPassword?.isEmpty)! || (userRepeatPassword?.isEmpty)!){
            // Display alert message
            displayMyAlertMessage(userMessage: "Tous les champs doivent être complétés.", type:"Attention")
            return
        }
        
        //Check if passwords match
        if(userPassword != userRepeatPassword){
            // Display an alert message
            displayMyAlertMessage(userMessage: "Les mots de passes sont différents...", type:"Attention");
            return;
        }
        
        // Hash password
        let hash = userPassword?.sha1()
        
        // Create a document
        let create = PutDocumentOperation(body: ["username":userEmail ?? "no_username", "password":hash ?? "no_password"], databaseName: dbName) {(response, httpInfo, error) in
            if let error = error {
                print("Encountered an error while creating a document. Error:\(error)")
            } else {
                print("Created document \(String(describing: response?["id"])) with revision id \(String(describing: response?["rev"]))")
            }
        }
        client.add(operation:create)
        
        //Success message
        let refreshAlert = UIAlertController(title: "Félicitation", message: "Votre compte a été crée.", preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion:nil)
        }))
        self.present(refreshAlert, animated: true, completion: nil)
        
        return
    }
    
    func displayMyAlertMessage(userMessage:String, type:String){
        let myAlert = UIAlertController(title:type, message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"Ok", style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
    }
    
    
    
}


