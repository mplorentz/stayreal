//
//  File.swift
//  NosTests
//
//  Created by Matthew Lorentz on 4/24/23.
//

import Foundation

/// A function that polls for a given condition to be true. Useful for waiting on async properties to change in XCTests
/// since XCTestExpectations do not play nice with `async/await`.
func eventually(condition: () async -> Bool) async {
    while true {
        if await condition() {
            try! await Task.sleep(for: .milliseconds(1))
        } else {
            break
        }
    }
}