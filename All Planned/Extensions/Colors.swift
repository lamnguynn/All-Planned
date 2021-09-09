//
//  Colors.swift
//  All Planned
//
//  Created by Lam Nguyen on 2/1/21.
//

import UIKit

extension UIColor{
    //Apply a sky blue color
    public static func applySkyBlueColor() -> UIColor{
        return UIColor(red: 203/255, green: 234/255, blue: 242/255, alpha: 1)
    }

    public static func applyTorqColor() -> UIColor{
        return UIColor(red: 162/255, green: 213/255, blue: 208/255, alpha: 1)
    }

    public static func applyLightRedColor() -> UIColor{
        UIColor(red: 226/255, green: 220/255, blue: 220/255, alpha: 1)
    }

    //Returns a powder red color
    public static func applyPowderRedColor() -> UIColor{
        return UIColor(red: 162/255 , green: 151/255, blue: 151/255, alpha: 1)
    }

    public static func applyPurpleColor() -> UIColor{
        return UIColor(red: 185/255, green: 158/255, blue: 235/255, alpha: 1)
    }

    public static func applyDarkGray() -> UIColor{
        return UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.7)
    }
}
