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
    
    @IBAction func slider_action(_ sender: UISlider) {

        if !sender.isTracking {
            sender.value = 0
        }
        
        DataOFBoard.sharedInstance.value = Int(round(sender.value))
        
        if sender.value < 0 {
            sender.minimumTrackTintColor = UIColor.red
        } else if sender.value == 0 {
            sender.minimumTrackTintColor = UIColor.blue
        } else {
            sender.minimumTrackTintColor = UIColor.green
        }
    }
    
    @objc func methodOfReceivedNotification() {
        if !slider.isTracking {
            slider.value = Float(DataOFBoard.sharedInstance.value)
        }
        var progress: Float = 0
        
        progress = (Float(DataOFBoard.sharedInstance.volt) - 790) / (979 - 790)

        progress = progress < 0 ? 0 : progress
        progress = progress > 1 ? 1 : progress
        
        ProgressBar.progress = progress
        
        if progress <= 0.3 {
            ProgressBar.progressTintColor = UIColor.red
        }
        else if progress > 0.7 {
            ProgressBar.progressTintColor = UIColor.green
        }
        else
        {
            ProgressBar.progressTintColor = UIColor.blue
        }
        
        
        Batery.text = String(format: "Batery: %.2fV", Float(DataOFBoard.sharedInstance.volt) * 1.1 * 16 / 1024)
        Cell.text = String(format: "Cell: %.2fV", Float(DataOFBoard.sharedInstance.volt) * 1.1 * 16 / 1024 / 4)
        Speed.text = String(format: "Speed: %iKm/h", DataOFBoard.sharedInstance.rpm)
        
        self.view.setNeedsDisplay()
    }
    
    // MARK: Funkcje
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.slider.transform = CGAffineTransform(rotationAngle: -(.pi / 2))
        
        self.methodOfReceivedNotification()
        //self.slider.thumbImage(for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataOFBoard.sharedInstance.sendSpeedTimer.start(seconds: 0.2)
        DataOFBoard.sharedInstance.readValueTimer.start(seconds: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification), name: NSNotification.Name(rawValue: "DataBluetoothChanged"), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataOFBoard.sharedInstance.sendSpeedTimer.stop(seconds: 0.2)
        DataOFBoard.sharedInstance.readValueTimer.stop(seconds: 1)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DataBluetoothChanged"), object: nil)
    }
}

