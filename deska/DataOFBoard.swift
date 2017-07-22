//
//  DataOFBoard.swift
//  deska
//
//  Created by MacBook on 16.07.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import Foundation
import CoreBluetooth

class DataOFBoard: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{
    
    // MARK: Stale
    
    let BEAN_SERVICE_UUID: CBUUID = CBUUID(string: "a495ff20-c5b1-4b44-b512-1370f02d74de")
    let BEAN_CHARACTERISTIK_UUID: CBUUID = CBUUID(string: "a495ff21-c5b1-4b44-b512-1370f02d74de")
    
    
    
    // MARK: Dane
    
    var manager: CBCentralManager? //menadzer urzadzen
    var peripheral: CBPeripheral? //urzadzenie
    var mainCharacteristic: CBCharacteristic? //charakterystyka polaczenia
    private var mainString: NSString = ""
    private var sendSpeedTimer: NSTimer?
    private var readValueTimer: NSTimer?
    
    // MARK: SharedInstance
    
    static let sharedInstance = DataOFBoard()
    
    // MARK: Akcje
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state){
        case .PoweredOn: break
        default:
            disconnect()
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        disconnect()
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            
            if service.UUID == BEAN_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (service.UUID == BEAN_SERVICE_UUID) {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.UUID == BEAN_CHARACTERISTIK_UUID) {
                    //we'll save the reference, we need it to write data
                    mainCharacteristic = characteristic
                    
                    //Set Notify is useful to read incoming data async
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                    print("Found Bluno Data Characteristic")
                    ///Wysylaj AT co 1 sekunde az do uzyskania OK lub 5 sekund
                    
                    sendData("ATI1") ///zapytaj o wszystkie dane
                }
                
            }
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if characteristic.UUID == BEAN_CHARACTERISTIK_UUID{
            if characteristic.value != nil{
                let stringValue = NSString(data: characteristic.value!, encoding: NSASCIIStringEncoding)!
                
                mainString = (mainString as String) + (stringValue as String)
                
                var changed: Bool = false
                
                while true{
                    let range = mainString.rangeOfString("\r" + "\n")
                    if range.location != NSNotFound {
                        
                        let line = mainString.substringToIndex(range.location) as NSString
                        
                        if line != "OK" {
                            let range = line.rangeOfString(": ")
                            
                            if range.location != NSNotFound {
                                let command = line.substringToIndex(range.location)
                                let data = line.substringFromIndex(range.location + 2)
                                
                                switch(command){
                                case "+RRPM" :
                                    rpm = UInt(data) ?? 0
                                case "+RBAT" :
                                    volt = UInt(data) ?? 0
                                case "+RTBA" :
                                    temp = Int(data) ?? 0
                                case "+RTDR" :
                                    tempOfControler = Int(data) ?? 0
                                case "+RWEI" :
                                    weight = UInt(data) ?? 0
                                case "+LED1" :
                                    _led1 = data == "1"
                                case "+LED2" :
                                    _led2 = data == "1"
                                case "+SAKC" :
                                    _acceleration = UInt(data) ?? 0
                                case "+SBRK" :
                                    _maxBreak = UInt(data) ?? 0
                                case "+SBSE" :
                                    _requiredBoardSensor = data == "1"
                                case "+SMOD" :
                                    _controlMode = UInt(data) ?? 0
                                case "+SMAC" :
                                    _battery = UInt(data) ?? 0
                                default: break
                                }
                                print(command + "=>" + data)
                                
                                changed = true
                            }
                            else{
                                print("Linia \(line)")
                            }
                        }
                        else{
                            print("OKKKK")
                        }
                        
                        mainString = mainString.substringFromIndex(range.location + 2)
                    }
                    else{
                        break
                    }
                }
                print("Zostalo \(mainString)")
                
                if changed {
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "DataBluetoothChanged", object: self))
                }
            }
        }
    }
    
    private func sendData(data: NSData){
        if peripheral != nil && mainCharacteristic != nil{
            peripheral?.writeValue(data, forCharacteristic: mainCharacteristic!, type: .WithoutResponse)
        }
        else{
            print("Data not send:\(NSString(data: data, encoding: NSASCIIStringEncoding))")
        }
    }
    
    private func sendData(data: String){
        if let encodedData = (data + "\r" + "\n").dataUsingEncoding(NSASCIIStringEncoding) {
            sendData(encodedData)
        }
        else{
            print("Dane nie mogły być przekształcone")
        }
    }
    
    ///Maksymalnie 4 komendy po drodze potem jest źle
    
    // MARK: Funkcje
    
    private override init(){
        super.init()
    }
    
    func connectDevice(peripheral per: CBPeripheral, manager man: CBCentralManager){
        disconnect()
        
        peripheral = per
        manager = man
        
        peripheral?.delegate = self
        manager?.delegate = self
        
        connected = peripheral?.name ?? peripheral?.identifier.UUIDString ?? ""
        
        peripheral?.discoverServices(nil)
    }
    
    func disconnect(){
        manager?.cancelPeripheralConnection(peripheral!)
        if (manager != nil){
            _connected = ""
        }
        manager = nil
        peripheral = nil
        mainCharacteristic = nil
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "DataBluetoothDisconnectd", object: self))
    }
    
    // MARK: Funkcje do deski
    
    func reboot(){
        sendData("AT+RST");
    }
    
    func startTimerSpeedValue(){
        sendSpeedTimer?.invalidate()
        
        sendSpeedTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(DataOFBoard.sendSpeedValue), userInfo: nil, repeats: true)
        
        sendSpeedTimer?.fire()
    }
    
    func stopTimerSpeedValue(){
        sendSpeedTimer?.invalidate()
    }
    
    func startTimerReadValue(){
        readValueTimer?.invalidate()
        
        readValueTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(DataOFBoard.readReadValue), userInfo: nil, repeats: true)
        
        readValueTimer?.fire()
    }
    
    func stopTimerReadValue(){
        readValueTimer?.invalidate()
    }
    
    @objc private func sendSpeedValue(){
        let dane = UnsafeMutablePointer<UInt8>.alloc(2)
        
        dane[0] = UInt8(_value)
        dane[1] = 0
        
        let crc = crc8(dane, 2)
        
        dane.dealloc(2)
        
        sendData("AT+SPED=\(_value),0,\(crc)")
    }
    
    @objc private func readReadValue(){
        //zamien na liste 4 komend w powietrzu
        sendData("AT+RRPM?")
        sendData("AT+RBAT?")
        sendData("AT+RTBA?")
        sendData("AT+RTDR?")
        sendData("AT+RWEI?")
    }
    
    // MARK: Zmienne do odczytu
    
    private var _connected: String?
    private(set) var connected: String{
        set
        {
            _connected = newValue
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "DataBluetoothConnected", object: self))
        }
        get
        {
            return _connected ?? ""
        }
    }
    
    
    private(set) var rpm: UInt = 0
    private(set) var volt: UInt = 0
    private(set) var temp: Int = 0
    private(set) var tempOfControler: Int = 0
    private(set) var weight: UInt = 0
    
    // MARK: Zmienne do odczytu i zapisu
    
    ///Wysylaj co 0,25 sekundy
    private var _value: UInt = 0
    var value: UInt{
        set
        {
            if newValue != _value {
                _value = newValue
                
                sendSpeedValue()
            }
        }
        get
        {
            return _value ?? 0
        }
    }
    
    var _led1 :Bool = false
    var led1: Bool{
        set{
            if newValue != _led1 {
                _led1 = newValue
                sendData("AT+LED1=\(_led1 ? 1 : 0)")
            }
        }
        get{
            return _led1
        }
    }
    
    var _led2 :Bool = false
    var led2: Bool{
        set{
            if newValue != _led2 {
                _led2 = newValue
                sendData("AT+LED2=\(_led2 ? 1 : 0)")
            }
        }
        get{
            return _led2
        }
    }
    
    var _acceleration: UInt = 0
    var acceleration: UInt{
        set{
            if newValue != _acceleration {
                _acceleration = newValue
                sendData("AT+SAKC=\(_acceleration)")
            }
        }
        get{
            return _acceleration
        }
    }
    
    var _maxBreak: UInt = 0
    var maxBreak: UInt{
        set{
            if newValue != _maxBreak {
                _maxBreak = newValue
                sendData("AT+SBRK=\(_maxBreak)")
            }
        }
        get{
            return _maxBreak
        }
    }
    
    var _requiredBoardSensor: Bool = false
    var requiredBoardSensor: Bool{
        set{
            if newValue != _requiredBoardSensor {
                _requiredBoardSensor = newValue
                sendData("AT+SBSE=\(_requiredBoardSensor ? 1 : 0)")
            }
        }
        get{
            return _requiredBoardSensor
        }
    }
    
    var _controlMode: UInt = 0
    var controlMode: UInt{
        set{
            if newValue != _controlMode {
                _controlMode = newValue
                sendData("AT+SMOD=\(_controlMode)")
            }
        }
        get{
            return _controlMode
        }
    }
    
    var _battery: UInt = 0
    var battery: UInt{
        set{
            if newValue != _battery {
                _battery = newValue
                sendData("AT+SMAC=\(_battery)")
            }
        }
        get{
            return _battery
        }
    }
    
    
}

/*
 extension Bool: IntValue {
 func intValue() -> Int {
 if self {
 return 1
 }
 return 0
 }
 }
 
 extension Int {
 init(_ bool:Bool) {
 self = bool ? 1 : 0
 }
 }
 
 
 */