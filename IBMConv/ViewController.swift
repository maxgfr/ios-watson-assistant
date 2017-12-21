//
//  ViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 21/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit
import Eureka

class ViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
            <<< TextRow(){ row in
                row.title = "Name"
            }
            <<< DateRow(){
                $0.title = "Birthdate"
                $0.value = Date()
                }
    }
}
