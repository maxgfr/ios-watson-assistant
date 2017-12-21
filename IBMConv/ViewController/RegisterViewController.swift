//
//  RegisterViewController.swift
//  IBMConv
//
//  Created by GOLFIER on 21/12/2017.
//  Copyright © 2017 GOLFIER. All rights reserved.
//

import UIKit
import Eureka

class RegisterViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rulesMail = RuleSet<String>()
        rulesMail.add(rule: RuleRequired())
        rulesMail.add(rule: RuleEmail())
        
        var rulesNormal = RuleSet<String>()
        rulesNormal.add(rule: RuleRequired())
        
        form +++ Section("Informations personnelles")
            <<< TextRow(){ row in
                row.title = "Non"
                row.placeholder = "Entrer votre nom ici"
                row.add(ruleSet: rulesNormal)
                row.validationOptions = .validatesOnChangeAfterBlurred
            }
            <<< TextRow(){ row in
                row.title = "Prénom"
                row.placeholder = "Entrer votre prénom ici"
                row.add(ruleSet: rulesNormal)
                row.validationOptions = .validatesOnChangeAfterBlurred
            }
            <<< EmailRow(){ row in
                row.title = "E-mail"
                row.placeholder = "Entrer votre e-mail ici"
                row.add(ruleSet: rulesMail)
                row.validationOptions = .validatesOnChangeAfterBlurred
            }
            <<< PasswordRow(){ row in
                row.title = "Mot de passe"
                row.placeholder = "Entrer votre mot de passe ici"
                row.add(ruleSet: rulesNormal)
                row.validationOptions = .validatesOnChangeAfterBlurred
        }
        
    }
}


