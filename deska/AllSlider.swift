//
//  AllSlider.swift
//  deska
//
//  Created by MacBook on 26.10.2017.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit

class AllSlider: UISlider
{
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
}
