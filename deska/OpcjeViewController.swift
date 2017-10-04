//
//  OpcjeViewController.swift
//  deska
//
//  Created by MacBook on 16.07.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit

class OpcjeViewController: UITableViewController {
    
    // MARK: Dane
    
    let controlNames = ["Slow", "Normal", "gt", "Lerning", "Custiom"]
    
    // MARK: Akcje
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4 //blututh, dane i opcje, o tworcach
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 8
        case 3:
            return 1
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section)
        {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Connect", for: indexPath)
            
            cell.textLabel?.text = "Addres: \(DataOFBoard.sharedInstance.connected)"
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Data", for: indexPath)
            
            switch(indexPath.row){
            case 0:
                cell.textLabel?.text = "RPM: \(DataOFBoard.sharedInstance.rpm)"
            case 1:
                cell.textLabel?.text = "Volt: \(Float(DataOFBoard.sharedInstance.volt) * 1.1 * 16 / 1024)V"
            case 2:
                cell.textLabel?.text = "Temperature: \(DataOFBoard.sharedInstance.temp)"
            case 3:
                cell.textLabel?.text = "Temperature of the controller: \(DataOFBoard.sharedInstance.tempOfControler)"
            case 4:
                cell.textLabel?.text = "Wight: \(DataOFBoard.sharedInstance.weight)"
            default:
                cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
            }
            
            return cell
        case 2:
            switch(indexPath.row){
            case 1, 2, 5:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BoolOptions", for: indexPath) as! BoolOptionsViewCell
                
                switch(indexPath.row){
                case 1:
                    cell.label.text = "Led 1:"
                    cell.Switch.isOn = DataOFBoard.sharedInstance.led1
                    cell.handle = {action in DataOFBoard.sharedInstance.led1 = action.isOn}
                    break
                case 2:
                    cell.label.text = "Led 2:"
                    cell.Switch.isOn = DataOFBoard.sharedInstance.led2
                    cell.handle = {action in DataOFBoard.sharedInstance.led2 = action.isOn}
                case 5:
                    cell.label.text = "Require a board sensor:"
                    cell.Switch.isOn = DataOFBoard.sharedInstance.requiredBoardSensor
                    cell.handle = {action in DataOFBoard.sharedInstance.requiredBoardSensor = action.isOn}
                default:
                    cell.label.text = "Section \(indexPath.section) Row \(indexPath.row)"
                }
                
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Options", for: indexPath)
                
                switch(indexPath.row){
                case 0:
                    cell.textLabel?.text = "Reboot"
                case 3:
                    cell.textLabel?.text = "Max acceleration: \(DataOFBoard.sharedInstance.acceleration)"
                case 4:
                    cell.textLabel?.text = "Max break: \(DataOFBoard.sharedInstance.maxBreak)"
                case 6:
                    cell.textLabel?.text = "Control mode: \(controlNames[Int(DataOFBoard.sharedInstance.controlMode)])"
                case 7:
                    cell.textLabel?.text = "Minimum batery: \(DataOFBoard.sharedInstance.battery)"
                default:
                    cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"
                }
                
                return cell
                
            }
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "About", for: indexPath)
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section)
        {
        case 0:
            return "Bluetooth"
        case 1:
            return "Data"
        case 2:
            return "Option"
        case 3:
            return "About"
        default:
            return "Section \(section)"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            switch(indexPath.row){
            case 0:
                let alert = UIAlertController(title: "Reboot", message: "Do you want to reboot board", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {action in
                    DataOFBoard.sharedInstance.reboot()
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                self.tableView.deselectRow(at: indexPath, animated: true)
            case 1, 2, 5: break
                //performSegueWithIdentifier("Bool", sender: indexPath.row)
            case 3, 4, 7:
                //performSegueWithIdentifier("Value", sender: indexPath.row)
                let alert = UIAlertController(title: "Title", message: nil, preferredStyle: .alert)
                
                switch(indexPath.row){
                case 3:
                    alert.title = "Max acceleration"
                case 4:
                    alert.title = "Max break"
                case 7:
                    alert.title = "Minimum batery"
                default:
                    alert.title = "Section \(indexPath.section) Row \(indexPath.row)"
                }
                
                alert.addTextField(configurationHandler: {text in
                    text.placeholder = "Please input"
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    if let text = alert.textFields?[0].text {
                        switch(indexPath.row){
                        case 3:
                            DataOFBoard.sharedInstance.acceleration = UInt(text) ?? DataOFBoard.sharedInstance.acceleration
                        case 4:
                            DataOFBoard.sharedInstance.maxBreak = UInt(text) ?? DataOFBoard.sharedInstance.maxBreak
                        case 7:
                            DataOFBoard.sharedInstance.battery = UInt(text) ?? DataOFBoard.sharedInstance.battery
                        default:
                            print("Section \(indexPath.section) Row \(indexPath.row) action didSelectRowAtIndexPath")
                        }
                        //Int(text)
                        self.tableView.reloadData()
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                self.tableView.deselectRow(at: indexPath, animated: true)
            case 6:
                let alert = UIAlertController(title: "Control mode", message: nil, preferredStyle: .actionSheet)

                for index in 0..<controlNames.count {
                    alert.addAction(UIAlertAction(title: controlNames[index], style: .default, handler: {action in
                        DataOFBoard.sharedInstance.controlMode = UInt(index)
                        self.tableView.reloadData()
                    }))
                }
                
                alert.actions[Int(DataOFBoard.sharedInstance.controlMode)].isEnabled = false
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
                
                self.tableView.deselectRow(at: indexPath, animated: true)
                //performSegueWithIdentifier("Control", sender: indexPath.row)
            default: break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Bluetooth" {
            //let bluetoothView : BluetoothViewController = segue.destinationViewController as! BluetoothViewController
            
            //set the manager's delegate to the scan view so it can call relevant connection methods
            //manager?.delegate = scanController
            //scanController.manager = manager
            //scanController.parentView = self
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataOFBoard.sharedInstance.startTimerReadValue()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tableView.reloadData), name: NSNotification.Name(rawValue: "DataBluetoothChanged"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DataOFBoard.sharedInstance.stopTimerReadValue()

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "DataBluetoothChanged"), object: nil)
    }
}

