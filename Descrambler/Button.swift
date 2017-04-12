//
//  Button.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/6/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import UIKit

class Button: UIButton {
    let ratio: CGFloat = 0.1
    
    var activityIndicator: UIActivityIndicatorView?
    
    init(text: String, target: Any?, selector: Selector, activity: Bool = false) {
        super.init(frame: CGRect.zero)
        
        setTitle(text, for: .normal)
        addTarget(target, action: selector, for: .touchUpInside)
        
        setTitleColor(UIColor.red, for: .normal)
        backgroundColor = UIColor.blue
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
        
        setTitleColor(UIColor.green, for: .highlighted)
        
        if activity {
            addActivityView()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityIndicator?.center = CGPoint(x: frame.width - (activityIndicator!.frame.width / 2) - 15, y: frame.height / 2)
    }
    
    func addActivityView() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator?.hidesWhenStopped = true
        addSubview(activityIndicator!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func _setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1 : 0.5
    }
    
    func startActivity() {
        activityIndicator?.startAnimating()
    }
    
    func stopActivity() {
        activityIndicator?.stopAnimating()
    }
}
