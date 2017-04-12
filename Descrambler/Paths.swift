//
//  Paths.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/4/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation

enum Direction: String {
    case UpLeft = "UpLeft"
    case Up = "Up"
    case UpRight = "UpRight"
    case Right = "Right"
    case DownRight = "DownRight"
    case Down = "Down"
    case DownLeft = "DownLeft"
    case Left = "Left"
    case None = "None"
}

struct Letter {
    let char: Character
    
    func stringRepresentation() -> String {
        if char == "Q" {
            return "Qu"
        }
        return String([char])
    }
    
    static func randomLetter() -> Letter {
        return Letter(char: Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters).randomElement())
    }
}

struct Tile: Equatable {
    let position: (Int, Int)
    let letter: Letter?
    
    func isNeighbor(other: Tile) -> Bool {
        return abs(position.0 - other.position.0) <= 1 && abs(position.1 - other.position.1) <= 1
    }
    
    func directionTowardsTile(other: Tile) -> Direction {
        if (position.0 == other.position.0) {
            if position.1 < other.position.1 {
                return .Down
            } else if position.1 == other.position.1 {
                return .None
            }
            else {
                return .Up
            }
        } else if (position.0 < other.position.0) {
            if position.1 < other.position.1 {
                return .DownRight
            } else if position.1 == other.position.1 {
                return .Right
            } else {
                return .UpRight
            }
        } else {
            if position.1 < other.position.1 {
                return .DownLeft
            } else if position.1 == other.position.1 {
                return .Left
            } else {
                return .UpLeft
            }
        }
    }
}

func ==(left: Tile, right: Tile) -> Bool {
    return left.position == right.position
}

class Board {
    var tiles: [Tile]
    let size: Int
    
    var name: String?
    var modified = false {
        didSet {
            boardModifiedEvent.raise(data: modified)
        }
    }
    
    let boardModifiedEvent = Event<Bool>()
    
    init(tiles: [Tile], size: Int) {
        assert(tiles.count == size * size, "Board must have size*size tiles.")
        
        self.tiles = tiles
        self.size = size
    }
    
    init(serialized: String, name: String? = nil) {
        self.name = name

        let size = Int(sqrt(Double(serialized.length)))
        self.size = size
        
        assert(size * size == serialized.length, "Serialized board must be square")
        
        var theTiles = [Tile]()
        
        for row in 0..<self.size {
            for column in 0..<self.size {
                let char: Character = serialized[row * self.size + column]
                theTiles.append(Tile(position: (row, column), letter: char != "_" ? Letter(char: char) : nil))
            }
        }
        
        self.tiles = theTiles
    }
    
    static func newBoard(size: Int, random: Bool = false) -> Board {
        var newTiles = [Tile]()
        for row in 0..<size {
            for column in 0..<size {
                let newTile = Tile(position: (row, column), letter: random ? Letter.randomLetter() : nil)
                newTiles.append(newTile)
            }
        }
        return Board(tiles: newTiles, size: size)
    }
    
    func tileAtPosition(position: (Int, Int)) -> Tile {
        return tiles[position.0 * size + position.1]
    }
    
    func setTileAtPosition(position: (Int, Int), tile newTile: Tile) {
        let oldTile = tileAtPosition(position: position)
        if let index = tiles.index(of: oldTile) {
            tiles[index] = newTile
        }
    }
    
    func isComplete() -> Bool {
        return tiles.reduce(true) { $0 && $1.letter != nil }
    }
    
    func serialize() -> String {
        return tiles.reduce("") { $0 + String($1.letter?.char ?? "_") }
    }
}

struct Path {
    let tiles: [Tile]
    
    func stringRepresentation() -> String {
        var str = String()
        for tile in tiles {
            if let letter = tile.letter {
                str.append(letter.stringRepresentation())
            }
        }
        return str
    }
    
    func isValid() -> Bool {
        return WordManager.sharedInstance.beginsWord(startingChars: stringRepresentation())
    }
    
    func isWord() -> Bool {
        return WordManager.sharedInstance.isWord(word: stringRepresentation())
    }
    
    func viableNexts(board: Board) -> [Tile] {
        if let lastTile = tiles.last {
            return board.tiles.filter { lastTile.isNeighbor(other: $0) && !tiles.contains($0) }
        }
        return [Tile]()
    }
    
    func pathByExtendingWithTile(tile: Tile) -> Path {
        var newTiles = tiles
        newTiles.append(tile)
        return Path(tiles: newTiles)
    }
    
    func validNextPaths(board: Board) -> [Path] {
        return viableNexts(board: board).map { pathByExtendingWithTile(tile: $0) }.filter { $0.isValid() }
    }
}

class Solution {
    let word: String
    let board: Board
    var paths: [Path]
    
    init(word: String, board: Board, paths: [Path] = [Path]()) {
        self.word = word
        self.board = board
        self.paths = paths
    }
    
    static func solution(forWord word: String, inSolutions solutions: [Solution]) -> Solution? {
        for solution in solutions {
            if solution.word == word {
                return solution
            }
        }
        return nil
    }
    
    func addPath(path: Path) {
        paths.append(path)
    }
}

class PathFinder {
    static func solveBoard(board: Board) -> [Solution] {
        var solutions = [Solution] ()
        
        var viablePaths = [Path]()
        for tile in board.tiles {
            viablePaths.append(Path(tiles: [tile]))
        }
        while !viablePaths.isEmpty {
            if let path = viablePaths.first {
                viablePaths.removeFirst()
                
                if path.isWord() {
                    let word = path.stringRepresentation().lowercased()
                    if let solution = Solution.solution(forWord: word, inSolutions: solutions) {
                        solution.addPath(path: path)
                    } else {
                        let newSolution = Solution(word: word, board: board, paths: [path])
                        solutions.append(newSolution)
                    }
                }
                
                viablePaths.append(contentsOf: path.validNextPaths(board: board))
            }
        }
        
        return solutions
    }
}
