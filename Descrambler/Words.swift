//
//  Words.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/4/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

// http://stackoverflow.com/a/33674192
extension Collection {
    /// Searches for an item in a sorted list.
    ///
    /// - parameters:
    ///     - predicate: A function which computes a `ComparisonResult` for a given element.
    /// - returns: Whether or not an item in the collection satisfies the predicate
    func binarySearch(predicate: (Iterator.Element) -> ComparisonResult) -> Bool {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            let result = predicate(self[mid])
            if result == .orderedSame {
                return true
            } else if  result == .orderedAscending {
                low = index(mid, offsetBy: 1)
            } else {
                high = mid
            }
        }
        return false
    }
}

class WordManager {
    static var sharedInstance = WordManager()
    
    var words = [String]()
    
    init() {
        loadWordList()
    }
    
    func loadWordList() {
        if let path = Bundle.main.path(forResource: Defaults[.wordList].rawValue, ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                words = data.components(separatedBy: ", ")
            } catch {
                print(error) // FIXME: Better exception handling
            }
        }
    }
    
    func beginsWord(startingChars: String) -> Bool {
        let lowercased = startingChars.lowercased()
        return words.binarySearch { word in
            if word.hasPrefix(lowercased) {
                return .orderedSame
            }
            return word.compare(lowercased)
        }
    }
    
    func isWord(word aWord: String) -> Bool {
        guard aWord.length >= 3 else { return false }
        let lowercased = aWord.lowercased()
        return words.binarySearch(predicate: { word in
            return word.compare(lowercased)
        })
    }
    
}
