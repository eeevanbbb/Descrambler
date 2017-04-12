//
//  GridView.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/4/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import UIKit

class GridView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let size: Int
    var board: Board? {
        didSet {
            reloadData()
        }
    }
    var editable = false {
        didSet {
            reloadData()
        }
    }
    var solutionPath: Path? = nil {
        didSet {
            reloadData()
        }
    }

    init(frame: CGRect, size: Int, board: Board? = nil, editable: Bool = false) {
        self.size = size
        self.board = board
        self.editable = editable
                
        let spaceRatio: CGFloat = 0.15 // ratio of space between tiles to tiles
        let fullWidth = frame.width - 0.1 // 0.1 for floating point issues so rows don't wrap
        let tileSize = fullWidth / (CGFloat(size) + (CGFloat(size) + 1) * spaceRatio)
        let space = tileSize * spaceRatio
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: tileSize, height: tileSize)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsetsMake(space, 0, 0, 0)
        layout.minimumInteritemSpacing = space
        
        super.init(frame: frame, collectionViewLayout: layout)
                
        register(TileView.self, forCellWithReuseIdentifier: "tile")
        register(SolutionTileView.self, forCellWithReuseIdentifier: "solutionTile")
        
        delegate = self
        dataSource = self
        
        isScrollEnabled = false
        contentInset = UIEdgeInsets(top: 0, left: space, bottom: space, right: space)

        backgroundColor = UIColor.white
        layer.borderColor = UIColor.orange.cgColor
        layer.borderWidth = 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = solutionPath == nil ? "tile" : "solutionTile"
        let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let tileView = cell as? TileView {
            let position = (indexPath.row, indexPath.section)
            tileView.position = position
            tileView.editable = editable
            tileView.board = board
            tileView.tag = indexPath.section * size + indexPath.row + 1
            if let board = board {
                let tile = board.tileAtPosition(position: position)
                tileView.letter = tile.letter
                tileView.updateTileText()
                
                if let solutionTileView = tileView as? SolutionTileView {
                    if let path = solutionPath {
                        if let index = path.tiles.index(of: tile) {
                            solutionTileView.alpha = 1.0
                            solutionTileView.number = index + 1
                            
                            if index + 1 < path.tiles.count {
                                solutionTileView.direction = tile.directionTowardsTile(other: path.tiles[index + 1])
                            } else {
                                solutionTileView.direction = Direction.None
                            }
                        } else {
                            solutionTileView.number = nil
                            solutionTileView.direction = nil
                            solutionTileView.alpha = 0.5
                        }
                    }
                }
            }
        }
        
        return cell
    }
}
