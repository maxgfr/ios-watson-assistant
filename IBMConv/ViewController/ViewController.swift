//
//  ViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 21/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit
import SwiftyButton

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = PressableButton()
        button.colors = .init(button: .cyan, shadow: .blue)
        button.shadowHeight = 5
        button.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


