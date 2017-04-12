//
//  BoardManager.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/4/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

class BoardManager {
    static var sharedInstance = BoardManager()
    
    let currentBoardChangedCompletenessEvent = Event<Bool>()
    
    var savedBoardChangedCompletenessEvents = [String: Event<Bool>]()
    
    var currentBoard: Board?
    var currentBoardSize: Int {
        return Defaults[.boardSize]
    }
    var solvedCurrentBoard: [Solution]?
    
    func setRandomBoard() {
        currentBoard = Board.newBoard(size: currentBoardSize, random: true)
        
        currentBoardChangedCompletenessEvent.raise(data: true)
    }
    
    func solveCurrentBoard() {
        if let board = currentBoard {
            solvedCurrentBoard = solve(board: board)
        } else {
            solvedCurrentBoard = nil
        }
    }
    
    func solve(board: Board) -> [Solution]? {
        if board.isComplete() {
            return PathFinder.solveBoard(board: board)
        }
        return nil
    }
    
    typealias SolutionsCompletionHandler = ([Solution]?) -> ()
    func solveAsync(board: Board, completion: @escaping SolutionsCompletionHandler) {
        DispatchQueue.global(qos: .userInitiated).async {
            let solution = self.solve(board: board)
            DispatchQueue.main.async {
                completion(solution)
            }
        }
    }
    
    func solveCurrentBoardAsync(completion: @escaping (() -> ())) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.solveCurrentBoard()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func updateTileInCurrentBoard(atPosition position: (Int, Int), letter: Letter?) {
        if currentBoard == nil {
            currentBoard = Board.newBoard(size: currentBoardSize)
        }
        currentBoard!.setTileAtPosition(position: position, tile: Tile(position: position, letter: letter))
        
        currentBoardChangedCompletenessEvent.raise(data: currentBoard!.isComplete())
    }
    
    func updateTile(inBoard board: Board, atPosition position: (Int, Int), withLetter letter: Letter?) {
        board.setTileAtPosition(position: position, tile: Tile(position: position, letter: letter))
        board.modified = true
        
        // Call events
        if let event = changedCompletenessEventForSavedBoard(board) {
            event.raise(data: board.isComplete())
        }
    }
    
    func clearCurrentBoard() {
        currentBoard = nil
        solvedCurrentBoard = nil
        
        currentBoardChangedCompletenessEvent.raise(data: false)
    }

    func saveCurrentBoard(name: String) -> Bool {
        guard let currentBoard = currentBoard else { return false }
        
        if Defaults[.savedBoards].keys.contains(name) {
            return false
        }
        
        Defaults[.savedBoards][name] = currentBoard.serialize()
        
        return true
    }
    
    func updateSavedBoard(_ board: Board) -> Bool {
        if let name = board.name, Defaults[.savedBoards].keys.contains(name) {
            Defaults[.savedBoards][name] = board.serialize()
            board.modified = false
            return true
        }
        return false
    }
    
    func savedBoards() -> [String: Board] {
        var saved = [String: Board]()
        
        for (key, value) in Defaults[.savedBoards] {
            saved[key] = Board(serialized: value, name: key)
        }
        
        return saved
    }
    
    func deleteBoard(named name: String) {
        Defaults[.savedBoards].removeValue(forKey: name)
    }
    
    func changedCompletenessEventForSavedBoard(_ board: Board) -> Event<Bool>? {
        if let name = board.name {
            if let event = savedBoardChangedCompletenessEvents[name] {
                return event
            } else {
                let newBoardChangedCompletenessEvent = Event<Bool>()
                savedBoardChangedCompletenessEvents[name] = newBoardChangedCompletenessEvent
                return newBoardChangedCompletenessEvent
            }
        }
        return nil
    }
}
