//
//  BoolOptionsViewCell.swift
//  deska
//
//  Created by MacBook on 18.07.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit

class BoolOptionsViewCell: UITableViewCell{
    
    // MARK: Dane
    
    @IBOutlet var label: UILabel!
    @IBOutlet var Switch: UISwitch!
    
    var handle: ((UISwitch)->Void)?
    
    // MARK: Akcje
    
    @IBAction func valueChanged(_ sender: AnyObject) {
        handle?(sender as! UISwitch)
    }
    
}
