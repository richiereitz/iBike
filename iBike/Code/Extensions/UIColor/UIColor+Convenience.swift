//
//  UIColor+Convenience.swift
//  iBike
//
//  Created by richard.reitzfeld on 6/30/20.
//  Copyright © 2020 Richard Reitzfeld. All rights reserved.
//

import UIKit

extension UIColor {
    class func fromUndividedRGB(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }

    class func grayColor(with rgb: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor.fromUndividedRGB(red: rgb, green: rgb, blue: rgb, alpha: alpha)
    }
}
