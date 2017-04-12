//
//  UIViewExtensions.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/5/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func debugBorder(on: Bool = true) {
        layer.borderColor = on ? UIColor.red.cgColor : UIColor.clear.cgColor
        layer.borderWidth = on ? 3 : 0
    }
}

extension CGRect {
    /**
     Shrink the rect to the desired proportion, offsetting its origin so that it is centered in the original rect.
     
     - returns: The shrunken rect.
     */
    func shrink(ratio: CGFloat) -> CGRect {
        let xOffset = (self.width - (self.width * ratio)) / 2
        let yOffset = (self.height - (self.height * ratio)) / 2
        return CGRect(x: self.origin.x + xOffset, y: self.origin.y + yOffset, width: self.width * ratio, height: self.height * ratio)
    }
}
