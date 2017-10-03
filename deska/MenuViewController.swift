//
//  FirstViewController.swift
//  deska
//
//  Created by MacBook on 16.07.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    // MARK: Dane
    
    @IBOutlet var slider: UISlider!
    @IBOutlet var ProgressBar: UIProgressView!
    @IBOutlet var Batery: UILabel!
    @IBOutlet var Cell: UILabel!
    @IBOutlet var Speed: UILabel!
    
    // MARK: Akcje
    
    @IBAction func slider_action(sender: UISlider) {
        
    if !sender.tracking {
        sender.value = 0
    }
        
        DataOFBoard.sharedInstance.value = Int(round(sender.value))
        
        if sender.value < 0 {
            sender.minimumTrackTintColor = UIColor.redColor()
        } else if sender.value == 0 {
            sender.minimumTrackTintColor = UIColor.blueColor()
        } else {
            sender.minimumTrackTintColor = UIColor.greenColor()
        }
    }
    
    func methodOfReceivedNotification() {
        if !slider.tracking {
            slider.value = Float(DataOFBoard.sharedInstance.value)
        }
        var progress: Float = 0
        
        progress = (Float(DataOFBoard.sharedInstance.volt) - 790) / (979 - 790)
        
        progress < 0 ? 0 : progress
        progress > 0 ? 1 : progress
        
        ProgressBar.progress = progress
        
        Batery.text = "Batery: \(Float(DataOFBoard.sharedInstance.volt) * 1.1 * 16 / 1024)V"
        Cell.text = "Cell: \(Float(DataOFBoard.sharedInstance.volt) * 1.1 * 16 / 1024 / 4)V"
        Speed.text = "Speed: \(DataOFBoard.sharedInstance.rpm)Km/h"
    }
    
    // MARK: Funkcje
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.slider.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
        self.methodOfReceivedNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        DataOFBoard.sharedInstance.startTimerSpeedValue()
        DataOFBoard.sharedInstance.startTimerReadValue(10)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: "DataBluetoothChanged", object: DataOFBoard.sharedInstance)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataOFBoard.sharedInstance.stopTimerSpeedValue()
        DataOFBoard.sharedInstance.stopTimerReadValue()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DataBluetoothChanged", object: nil)
    }
}

