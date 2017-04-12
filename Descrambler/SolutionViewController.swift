//
//  SolutionViewController.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/5/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit
import SnapKit

class SolutionViewController: UIViewController {

    let solution: Solution
    var pathIndex: Int = 0
    
    var gridView: GridView?
    var numPathsLabel = Label(text: "")
    
    init(solution: Solution) {
        self.solution = solution
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func configureView() {
        navigationItem.title = solution.word
        
        view.backgroundColor = UIColor(colorLiteralRed: 211/250.0, green: 211/250.0, blue: 211/250.0, alpha: 0.7)
        
        gridView = GridView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), size: solution.board.size)
        gridView!.board = solution.board
        gridView!.editable = false
        gridView!.solutionPath = solution.paths[pathIndex]
        view.addSubview(gridView!)
        gridView!.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(gridView!.snp.width)
        }
        
        updateNumPathsLabel()
        view.addSubview(numPathsLabel)
        numPathsLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(gridView!.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(40)
        }
        
        let switchPathsButton = Button(text: "Next Path", target: self, selector: #selector(SolutionViewController.switchToNextPath))
        view.addSubview(switchPathsButton)
        switchPathsButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(numPathsLabel.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(40)
        }
        
        if solution.paths.count <= 1 {
            switchPathsButton._setEnabled(false)
        }
    }
    
    func switchToNextPath() {
        pathIndex = (pathIndex + 1) % solution.paths.count
        gridView?.solutionPath = solution.paths[pathIndex]
        updateNumPathsLabel()
    }
    
    func updateNumPathsLabel() {
        numPathsLabel.text = "Path \(pathIndex + 1) of \(solution.paths.count)"
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
