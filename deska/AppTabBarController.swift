//
//  AppTabBarController.swift
//  deska
//
//  Created by MacBook on 18.07.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit

class AppTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: Akcje
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let vc = viewController as? UINavigationController {
            vc.popToRootViewController(animated: false)
        }
    }
    
    // MARK: Funkcje
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
