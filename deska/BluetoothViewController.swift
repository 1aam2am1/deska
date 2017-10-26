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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Bluetooth", for: indexPath)
        
        let peripheral = peripherals[indexPath.row]

        cell.textLabel?.text = peripheral.name ?? peripheral.identifier.uuidString
        
        if cell.textLabel?.text == DataOFBoard.sharedInstance.connected {
            cell.accessoryType = .checkmark
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let peripheral = peripherals[indexPath.row]

        if DataOFBoard.sharedInstance.connected == self.tableView.cellForRow(at: indexPath)?.textLabel?.text {
            DataOFBoard.sharedInstance.disconnect()
            
            if let navController = self.navigationController {
                //*navController.popViewController(animated: true)
                navController.popViewController(animated: true)
            }
        }
        else {
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch(central.state)
        {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            fallthrough
        default:
            var message: String
            switch(central.state)
            {
            case .poweredOff:
                message = "Bluetooth is off"
            case .poweredOn:
                message = "OK?"
            case .resetting:
                message = "Bluetooth is resseting"
            case .unauthorized:
                message = "App is not authorized"
            case .unknown:
                message = "Unknown state of bluetooth"
            case .unsupported:
                message = "Bluetooth is unsuported"
            }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {action in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
        }
        
        self.tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        manager.stopScan()
        
        DataOFBoard.sharedInstance.connectDevice(peripheral: peripheral, manager: manager)
        
        if let navController = self.navigationController {
            //*navController.popViewController(animated: true)
            navController.popViewController(animated: true)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error ?? "")
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
