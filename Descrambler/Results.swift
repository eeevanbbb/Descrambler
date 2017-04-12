//
//  Results.swift
//  Descrambler
//
//  Created by Evan Bernstein on 4/5/17.
//  Copyright © 2017 Evan Bernstein. All rights reserved.
//

import Foundation

class Results {
    static func groupSolutions(withSolutions solutions: [Solution]) -> [Int: [Solution]] {
        var grouped = [Int: [Solution]]()
        
        for solution in solutions {
            let length = solution.word.length
            if grouped[length] == nil {
                grouped[length] = [Solution]()
            }
            grouped[length]!.append(solution)
        }
        
        return sortGroups(grouped: grouped)
    }
    
    static func sortGroups(grouped: [Int: [Solution]]) -> [Int: [Solution]] {
        var sorted = [Int: [Solution]]()
        
        for (key, val) in grouped {
            sorted[key] = val.sorted { sol1, sol2 in
                return sol1.word.compare(sol2.word) == .orderedAscending
            }
        }
        
        return sorted
    }
}
