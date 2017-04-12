//
//  Extensions.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/5/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension Array {
    /**
     Randomly choose an element from the array.
     
     - returns: The element chosen at random.
     */
    func randomElement() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}

extension String {
    func withNumber(num: Int, pluralForm: String? = nil) -> String {
        let plural = pluralForm ?? self.appending("s")
        let noun = num == 1 ? self : plural
        return "\(num) \(noun)"
    }
    
    var length: Int {
        return characters.count
    }
    
    // From here: http://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(start, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}

// MARK: - Settings

extension DefaultsKeys {
    static let wordList = DefaultsKey<WordList>("wordList")
    static let boardSize = DefaultsKey<Int>("boardSize")
    static let savedBoards = DefaultsKey<[String: String]>("savedBoards")
}

enum WordList: String {
    case ENABLE = "ENABLE"
    case TwoOfTwelve = "2of12"
    case EOWL = "EOWL"
}

extension UserDefaults {
    subscript(key: DefaultsKey<WordList>) -> WordList {
        get { return unarchive(key) ?? WordList.ENABLE }
        set { archive(key, newValue) }
    }
    
    subscript(key: DefaultsKey<[String: String]>) -> [String: String] {
        get { return unarchive(key) ?? [String: String]() }
        set { archive(key, newValue) }
    }
}

// Grabbed from gereon's 1/31/17 comment on:
// https://github.com/radex/SwiftyUserDefaults/pull/81
extension UserDefaults {
    func registerDefault<T: RawRepresentable>(_ key: DefaultsKey<T>, _ value: T) {
        Defaults.register(defaults: [ key._key: value.rawValue ])
    }
    
    func registerDefault<T>(_ key: DefaultsKey<T>, _ value: T) {
        Defaults.register(defaults: [ key._key: value ])
    }
}
