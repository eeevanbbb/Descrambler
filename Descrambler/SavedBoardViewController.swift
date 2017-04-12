//
//  SavedBoardViewController.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/6/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit

class SavedBoardViewController: UIViewController {
    
    let savedBoard: Board
    let name: String
    
    var boardCompletenessHandler: Disposable?
    var boardModifiedHandler: Disposable?
    
    init(savedBoard: Board, name: String) {
        self.savedBoard = savedBoard
        self.name = name
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        boardCompletenessHandler?.dispose()
        boardModifiedHandler?.dispose()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        automaticallyAdjustsScrollViewInsets = false
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var solveButton: Button?
    var updateButton: Button?
    
    func configureView() {
        navigationItem.title = name
        
        view.backgroundColor = UIColor(colorLiteralRed: 211/250.0, green: 211/250.0, blue: 211/250.0, alpha: 0.7)

        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(SavedBoardViewController.dismissKeyboard))
        view.addGestureRecognizer(tapGestureRec)
        
        let gridView = GridView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width), size: savedBoard.size, board: savedBoard, editable: true)
        view.addSubview(gridView)
        gridView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(gridView.snp.width)
        }
        
        solveButton = Button(text: "Solve", target: self, selector: #selector(SavedBoardViewController.solveBoard), activity: true)
        handleBoardChangeCompleteness(data: savedBoard.isComplete())
        boardCompletenessHandler = BoardManager.sharedInstance.changedCompletenessEventForSavedBoard(savedBoard)?.addHandler(target: self, handler: SavedBoardViewController.handleBoardChangeCompleteness)
        view.addSubview(solveButton!)
        solveButton!.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(gridView.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(40)
        }
        
        updateButton = Button(text: "Update", target: self, selector: #selector(SavedBoardViewController.updateButtonPressed))
        handleBoardModifiedEvent(data: savedBoard.modified)
        boardModifiedHandler = savedBoard.boardModifiedEvent.addHandler(target: self, handler: SavedBoardViewController.handleBoardModifiedEvent)
        view.addSubview(updateButton!)
        updateButton!.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(solveButton!.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(40)
        }
        
        
        
//        navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SavedBoardViewController.updateButtonPressed))
//        navigationItem.leftBarButtonItem = newBackButton
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func solveBoard() {
        solveButton?.startActivity()
        BoardManager.sharedInstance.solveAsync(board: savedBoard, completion: { solved in
            self.solveButton?.stopActivity()
            let resultsVC = ResultsTableViewController(solutions: solved)
            self.navigationController?.pushViewController(resultsVC, animated: true)
        })
    }
    
    func handleBoardChangeCompleteness(data complete: Bool) {
        solveButton?._setEnabled(complete)
    }
    
    func updateButtonPressed() {
        if BoardManager.sharedInstance.updateSavedBoard(savedBoard) {
            let successAlert = UIAlertController(title: "Success!", message: "Your updated board has been saved", preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "Okay!", style: .default, handler: nil))
            present(successAlert, animated: true, completion: nil)
        } else {
            let failureAlert = UIAlertController(title: "Something went wrong", message: "Unable to update your saved board", preferredStyle: .alert)
            failureAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(failureAlert, animated: true, completion: nil)
        }
    }
    
    func handleBoardModifiedEvent(data modified: Bool) {
        updateButton?._setEnabled(modified)
    }
    
    /*
    func backButtonPressed() {
        if !savedBoard.modified {
            goBack()
        } else {
            let unsavedAlertController = UIAlertController(title: "Save changes", message: "You have made changes to this board. Would you like to save them?", preferredStyle: .alert)
            unsavedAlertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                if BoardManager.sharedInstance.updateSavedBoard(self.savedBoard) {
                    self.goBack()
                } else {
                    let unsuccessfulAlertController = UIAlertController(title: "Save unsuccessful", message: "Something went wrong and your changes were not saved. Sorry about that!", preferredStyle: .alert)
                    unsuccessfulAlertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                        self.goBack()
                    }))
                    self.present(unsuccessfulAlertController, animated: true, completion: nil)
                }
            }))
            unsavedAlertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
                self.goBack()
            }))
            present(unsavedAlertController, animated: true, completion: nil)
        }
    }
    
    func goBack() {
        _ = navigationController?.popViewController(animated: true)
    }
 */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
