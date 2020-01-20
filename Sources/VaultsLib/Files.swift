//
//  Files.swift
//  
//
//  Created by Asaf Niv on 01/01/2020.
//  Copyright © 2020 Asaf Niv. All rights reserved.

import Foundation

public enum FileErrors: Error {
    case genericError
}

func writeToFile(path: String, contents: Data) throws {
    try contents.write(to: URL(fileURLWithPath: path))
}
func writeToIndex(vaultPath: String, what: Data) throws {
    do {
        try writeToFile(path: vaultPath+"/"+indexName, contents: what)
    } catch let error as NSError {
        print("COULD NOT WRITE TO INDEX: \(error.debugDescription)")
        throw FileErrors.genericError
    }
}

func readFile(path: String) throws -> Data {
    do {
        return try Data(contentsOf: URL.init(fileURLWithPath: path))
    } catch let error as NSError {
        print("Could not read file! Reason: \(error)")
        throw FileErrors.genericError
    }
}
