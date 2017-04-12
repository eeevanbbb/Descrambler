//
//  ViewController.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/4/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var board: Board?
    
    var gridView: GridView?
    var placeholderGridView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        automaticallyAdjustsScrollViewInsets = false
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if gridView?.size != BoardManager.sharedInstance.currentBoardSize {
            updateGridView()
            BoardManager.sharedInstance.clearCurrentBoard()
        }
    }
    
    deinit {
        boardCompletenessHandler?.dispose()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var boardCompletenessHandler: Disposable?
    
    var solveButton: Button?
    
    func configureView() {
        navigationItem.title = "Descrambler"
        
        view.backgroundColor = UIColor(colorLiteralRed: 211/250.0, green: 211/250.0, blue: 211/250.0, alpha: 0.7)
        
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRec)
        
        placeholderGridView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        placeholderGridView!.backgroundColor = UIColor.clear
        view.addSubview(placeholderGridView!)
        placeholderGridView!.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(placeholderGridView!.snp.width)
        }
        
        updateGridView()
        
        solveButton = Button(text: "Solve", target: self, selector: #selector(ViewController.solveBoard), activity: true)
        view.addSubview(solveButton!)
        handleBoardChangeCompleteness(data: BoardManager.sharedInstance.currentBoard?.isComplete() ?? false)
        solveButton?.snp.makeConstraints { (make) -> Void in
            make.top.lessThanOrEqualTo(placeholderGridView!.snp.bottom).offset(20)
            make.top.greaterThanOrEqualTo(placeholderGridView!.snp.bottom).offset(5)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(40).priority(500)
            make.height.lessThanOrEqualTo(40)
            make.height.greaterThanOrEqualTo(30)
        }
        boardCompletenessHandler = BoardManager.sharedInstance.currentBoardChangedCompletenessEvent.addHandler(target: self, handler: ViewController.handleBoardChangeCompleteness)
        
        let generateButton = Button(text: "Random", target: self, selector: #selector(ViewController.generateRandomBoard))
        view.addSubview(generateButton)
        generateButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(solveButton!.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(solveButton!.snp.height)
        }

        let saveButton = Button(text: "Save", target: self, selector: #selector(ViewController.saveButtonPressed))
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(generateButton.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(generateButton.snp.height)
        }
        
        let settingsButton = Button(text: "Settings / Saved Boards", target: self, selector: #selector(ViewController.openSettings))
        view.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(saveButton.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(saveButton.snp.height)
            make.bottom.lessThanOrEqualTo(view.snp.bottom).offset(-10)
        }
    }
    
    func handleBoardChangeCompleteness(data complete: Bool) {
        solveButton?._setEnabled(complete)
    }
    
    func updateGridView() {
        gridView?.removeFromSuperview()
        gridView = GridView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width), size: BoardManager.sharedInstance.currentBoardSize, editable: true)
        view.addSubview(gridView!)
        gridView?.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(placeholderGridView!.snp.top)
            make.left.equalTo(placeholderGridView!.snp.left)
            make.right.equalTo(placeholderGridView!.snp.right)
            make.height.equalTo(placeholderGridView!.snp.height)
            
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func generateRandomBoard() {
        BoardManager.sharedInstance.setRandomBoard()
        gridView?.board = BoardManager.sharedInstance.currentBoard
        gridView?.reloadData()
    }
    
    func solveBoard() {
        solveButton?.startActivity()
        BoardManager.sharedInstance.solveCurrentBoardAsync {
            self.solveButton?.stopActivity()
            let resultsVC = ResultsTableViewController()
            self.navigationController?.pushViewController(resultsVC, animated: true)
        }
    }
    
    func openSettings() {
        let settingsVC = SettingsViewController(style: .grouped)
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func saveButtonPressed() {
        if BoardManager.sharedInstance.currentBoard == nil {
            let emptyBoardAlert = UIAlertController(title: "Empty Board", message: "Cannot save an empty board", preferredStyle: .alert)
            emptyBoardAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(emptyBoardAlert, animated: true, completion: nil)
        } else {
            let nameBoardAlert = UIAlertController(title: "Name Board", message: "Give this board a name", preferredStyle: .alert)
            nameBoardAlert.addTextField { textField in
                textField.placeholder = "A unique name"
                textField.textColor = UIColor.black
            }
            nameBoardAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            nameBoardAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                var success = true
                var message = ""
                if let name = nameBoardAlert.textFields?.first?.text, name.length > 0, BoardManager.sharedInstance.saveCurrentBoard(name: name) {
                    message = "Board saved!"
                } else if let name = nameBoardAlert.textFields?.first?.text, name.length > 0 {
                    message = "There is already a saved board named \(name)"
                    success = false
                } else {
                    message = "You must give the board a name"
                    success = false
                }
                
                let successAlert = UIAlertController(title: success ? "Success!" : "Unable to save board", message: message, preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(successAlert, animated: true, completion: nil)
            }))
            present(nameBoardAlert, animated: true, completion: nil)
        }
    }
}

