//
//  TileView.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/4/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class TileTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        backgroundColor = UIColor.clear
        textColor = UIColor.black
        textAlignment = .center
        font = UIFont.systemFont(ofSize: frame.width / 2)
        autocorrectionType = .no
        autocapitalizationType = .allCharacters
        returnKeyType = .next
    }
    
    func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        
        if let tileView = superview as? TileView {
            tileView.goToNextTile(backwards: true)
        }
    }
}

class SolutionTileView: TileView {
    var direction: Direction? {
        didSet {
            configureSolutionView()
        }
    }
    var number: Int? {
        didSet {
            configureSolutionView()
        }
    }
    
    var arrowOverlayView: UIImageView?
    var numberLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSolutionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSolutionView() {
        if let direction = direction {
            arrowOverlayView?.removeFromSuperview()
            let arrowOverlayImage = UIImage(named: direction.rawValue)
            arrowOverlayView = UIImageView(image: arrowOverlayImage)
            arrowOverlayView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height).shrink(ratio: 0.7)
            arrowOverlayView?.alpha = 0.5
            addSubview(arrowOverlayView!)
        } else {
            arrowOverlayView?.removeFromSuperview()
        }
        
        if let number = number {
            numberLabel?.removeFromSuperview()
            let size = frame.width / 7
            numberLabel = UILabel(frame: CGRect(x: frame.width - size - (frame.width / 8), y: frame.height / 8, width: size, height: size))
            numberLabel?.font = UIFont.systemFont(ofSize: size)
            numberLabel?.minimumScaleFactor = 0.1
            numberLabel?.adjustsFontSizeToFitWidth = true
            numberLabel?.text = String(number)
            numberLabel?.textAlignment = .right
            numberLabel?.textColor = UIColor.black
            addSubview(numberLabel!)
        } else {
            numberLabel?.removeFromSuperview()
        }
    }
}

class TileView: UICollectionViewCell, UITextFieldDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var letter: Letter?
    var position = (-1, -1) {
        didSet {
            let size = board?.size ?? BoardManager.sharedInstance.currentBoardSize
            if position.0 + 1 == size && position.1 + 1 == size {
                changeTextFieldKeytype()
            }
        }
    }
    var editable = false {
        didSet {
            textField.isEnabled = editable
        }
    }
    var board: Board?
    
    private var textField: TileTextField
    
    override init(frame: CGRect) {
        textField = TileTextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        backgroundColor = UIColor.clear
        
        textField.delegate = self
        addSubview(textField)
        
        let tileImageView = UIImageView(image: UIImage(named: "Tile"))
        tileImageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        addSubview(tileImageView)
        sendSubview(toBack: tileImageView)
        
        updateTileText()
    }
    
    func updateTileText() {
        textField.text = letter?.stringRepresentation()
    }
    
    
    // MARK: - Text Field Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if editable {
            if range.length > 0 {
                letter = nil
            } else if "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(string.uppercased()), let first = string.uppercased().characters.first {
                letter = Letter(char: first)
                goToNextTile()
            }
            
            if let board = board, board.name != nil {
                BoardManager.sharedInstance.updateTile(inBoard: board, atPosition: position, withLetter: letter)
            } else {
                // It's the current board (either it's nil or it's nameless)
                BoardManager.sharedInstance.updateTileInCurrentBoard(atPosition: position, letter: letter)
            }
            updateTileText()
        }
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        goToNextTile()
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        superview?.bringSubview(toFront: self)
        KeyboardAvoiding.avoidingView = self
        // FIXME: There is a bug here when switching text fields by tapping on a new one, the old text field doesn't return to its original position. This is a bug with the KeyboardAvoiding library.
        // FIXME: On the saved boards GridView, constraints are broken and it doesn't work
        
        return true
    }
    
    
    
    func goToNextTile(backwards: Bool = false) {
        let size = board?.size ?? BoardManager.sharedInstance.currentBoardSize
        if let gridView = superview as? GridView {
            textField.resignFirstResponder()
            var nextTag = position.1 * size + position.0 + 2
            if backwards {
                nextTag -= 2
            }
            if let nextTileView = gridView.viewWithTag(nextTag) as? TileView {
                nextTileView.textField.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
    }
    
    func changeTextFieldKeytype() {
        textField.returnKeyType = .done
    }
}
