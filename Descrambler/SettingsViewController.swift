//
//  SettingsViewController.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/5/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import Static
import SwiftyUserDefaults

class SettingsViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dataSource.sections.count > 0 {
            // dataSource has been configured
            updateSavedBoardsCount()
        }
    }
    
    func configureView() {
        title = "Settings"
        
        tableView.rowHeight = 50
        
        let stepperAccessory = UIStepper()
        stepperAccessory.stepValue = 1
        stepperAccessory.minimumValue = 2
        stepperAccessory.maximumValue = 20
        stepperAccessory.value = Double(Defaults[.boardSize])
        stepperAccessory.addTarget(self, action: #selector(SettingsViewController.stepperChanged(stepper:)), for: .valueChanged)
        
        dataSource.sections = [
            Section(header: "Word List", rows: [
                Row(text: "ENABLE", selection: { [unowned self] in
                    self.update(wordList: .ENABLE)
                }),
                Row(text: "2of12", selection: {
                    self.update(wordList: .TwoOfTwelve)
                }),
                Row(text: "EOWL", selection: {
                    self.update(wordList: .EOWL)
                })
                ]),
            Section(header: "Board Size", rows: [
                Row(text: "\(Defaults[.boardSize]) x \(Defaults[.boardSize])", accessory: .view(stepperAccessory))
                ]),
            Section(header: "Saved Boards", rows: [
                Row(selection: {
                    let savedBoardsVC = SavedBoardsTableViewController()
                    self.navigationController?.pushViewController(savedBoardsVC, animated: true)
                }, accessory: .disclosureIndicator)
                ])
        ]
        
        updateWordListCheckmarks()
        updateSavedBoardsCount()
    }
    
    func update(wordList: WordList) {
        Defaults[.wordList] = wordList
        self.updateWordListCheckmarks()
        WordManager.sharedInstance.loadWordList()
    }
    
    func updateWordListCheckmarks() {
            dataSource.sections[0].rows[0].accessory = Defaults[.wordList] == .ENABLE ? .checkmark : .none
            dataSource.sections[0].rows[1].accessory = Defaults[.wordList] == .TwoOfTwelve ? .checkmark : .none
            dataSource.sections[0].rows[2].accessory = Defaults[.wordList] == .EOWL ? .checkmark : .none
    }
    
    func stepperChanged(stepper: UIStepper) {
        Defaults[.boardSize] = Int(stepper.value)
        dataSource.sections[1].rows[0].text = "\(Defaults[.boardSize]) x \(Defaults[.boardSize])"
    }
    
    func updateSavedBoardsCount() {
        dataSource.sections[2].rows[0].text = "board saved".withNumber(num: BoardManager.sharedInstance.savedBoards().keys.count, pluralForm: "boards saved")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
