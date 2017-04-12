//
//  Label.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/6/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import UIKit

class Label: UILabel {
    init(text: String, fontSize: CGFloat = 18) {
        super.init(frame: CGRect.zero)
        
        self.text = text
        font = UIFont.systemFont(ofSize: fontSize)
        sizeToFit()
        
        textAlignment = .center
        textColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
