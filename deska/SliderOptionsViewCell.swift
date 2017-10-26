//
//  SliderOptionsViewCell.swift
//  deska
//
//  Created by MacBook on 26.10.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit

class SliderOptionsViewCell: UITableViewCell{
    
    // MARK: Dane
    
    @IBOutlet var slider: UISlider!
    
    var handle: ((UISlider)->Void)?
    
    // MARK: Akcje
    
    @IBAction func valueChanged(_ sender: AnyObject) {
        handle?(sender as! UISlider)
    }
    
}
