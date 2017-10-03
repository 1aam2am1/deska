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
    
    // MARK: Akcje
    
    @IBAction func slider_action(sender: UISlider) {
        DataOFBoard.sharedInstance.value = Int(round(sender.value))
    }
    
    func methodOfReceivedNotification(notification: NSNotification){
        slider.value = Float(DataOFBoard.sharedInstance.value)
    }
    
    // MARK: Funkcje
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        DataOFBoard.sharedInstance.startTimerSpeedValue()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name: "DataBluetoothConnected", object: DataOFBoard.sharedInstance)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.methodOfReceivedNotification(_:)), name: "DataBluetoothDisconnectd", object: DataOFBoard.sharedInstance)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataOFBoard.sharedInstance.stopTimerSpeedValue()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DataBluetoothConnected", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DataBluetoothDisconnectd", object: nil)
    }
}

