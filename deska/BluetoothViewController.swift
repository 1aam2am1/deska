//
//  BluetoothViewController.swift
//  deska
//
//  Created by MacBook on 16.07.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UITableViewController, CBCentralManagerDelegate {
    
    // MARK: Dane
    
    var manager:CBCentralManager!
    var peripherals:[CBPeripheral] = []
    
    // MARK: Akcje
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Bluetooth", forIndexPath: indexPath)
        
        let peripheral = peripherals[indexPath.row]

        cell.textLabel?.text = peripheral.name ?? peripheral.identifier.UUIDString
        
        if cell.textLabel?.text == DataOFBoard.sharedInstance.connected {
            cell.accessoryType = .Checkmark
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let peripheral = peripherals[indexPath.row]

        if DataOFBoard.sharedInstance.connected == self.tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text {
            DataOFBoard.sharedInstance.disconnect()
            
            if let navController = self.navigationController {
                //*navController.popViewController(animated: true)
                navController.popViewControllerAnimated(true)
            }
        }
        else {
            manager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state)
        {
        case .PoweredOn:
            print("On")
            central.scanForPeripheralsWithServices(nil, options: nil)
        case .PoweredOff:
            fallthrough
        default:
            let alert = UIAlertController(title: nil, message: "Eroor Code: \(central.state.rawValue)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Destructive, handler: {action in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
        }
        
        self.tableView.reloadData()
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        manager.stopScan()
        
        DataOFBoard.sharedInstance.connectDevice(peripheral: peripheral, manager: manager)
        
        if let navController = self.navigationController {
            //*navController.popViewController(animated: true)
            navController.popViewControllerAnimated(true)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: NSError?) {
        print(error)
    }
    
    // MARK: Funckje
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
        peripherals = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}