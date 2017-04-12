//
//  SavedBoardsTableViewController.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/6/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit

class SavedBoardsTableViewCell: UITableViewCell {
    var boardName: String? {
        didSet {
            configureView()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        textLabel?.text = boardName
        
        accessoryType = .disclosureIndicator
    }
}

class SavedBoardsTableViewController: UITableViewController {
    
    var sortedNames = [String]()
    
    init() {
        super.init(style: .plain)
        
        updateKeys()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateKeys() {
        sortedNames = BoardManager.sharedInstance.savedBoards().keys.sorted()
        navigationItem.title = "saved board".withNumber(num: BoardManager.sharedInstance.savedBoards().keys.count)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.register(SavedBoardsTableViewCell.self, forCellReuseIdentifier: "savedBoard")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedBoard", for: indexPath)

        // Configure the cell...
        if let cell = cell as? SavedBoardsTableViewCell {
            let boardName = sortedNames[indexPath.row]
            if let boardSize = BoardManager.sharedInstance.savedBoards()[boardName]?.size {
                cell.boardName = "\(boardName) (\(boardSize) x \(boardSize))"
            } else {
                // I don't know why this would ever be the case
                cell.boardName = boardName
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = sortedNames[indexPath.row]
        if let board = BoardManager.sharedInstance.savedBoards()[name] {
            let savedBoardVC = SavedBoardViewController(savedBoard: board, name: name)
            navigationController?.pushViewController(savedBoardVC, animated: true)
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            BoardManager.sharedInstance.deleteBoard(named: sortedNames[indexPath.row])
            updateKeys()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
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
