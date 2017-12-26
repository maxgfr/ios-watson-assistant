//
//  ViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 21/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool){
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "Identifiant")
        if (username == nil) {
            self.performSegue(withIdentifier: "loginView", sender: self);
        } else {
            print(username!)
        }
    }

    @IBAction func onClickDeco(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "Identifiant")
        print("Deconnexion")
        self.performSegue(withIdentifier: "loginView", sender: self);
    }    
    
}
