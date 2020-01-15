//
//  Files.swift
//  
//
//  Created by Asaf Niv on 01/01/2020.
//

import Foundation

public enum FileErrors: Error {
    case genericError
}

func writeToFile(path: String, contents: String) throws {
    print("Writing to:", path)
    let data = contents.data(using: String.Encoding.ascii)!
    let file = (path as NSString).expandingTildeInPath
    do {
        try data.write(to: URL.init(fileURLWithPath: file))
    } catch  {
        print("Could not write index!")
    }
}
func writeToIndex(vaultPath: String, what: String) throws {
    do {
        try writeToFile(path: vaultPath+"/"+indexName, contents: what)
    } catch let error as NSError {
        print("COULD NOT WRITE TO INDEX: \(error.debugDescription)")
        throw FileErrors.genericError
    }
}

func readIndex(vaultPath: String) throws -> String {
    do {
        return try String(contentsOf: URL.init(fileURLWithPath: vaultPath + "/" + indexName))
    } catch let error as NSError {
        print("Could not read index! Reason: \(error)")
        throw FileErrors.genericError
    }
}
