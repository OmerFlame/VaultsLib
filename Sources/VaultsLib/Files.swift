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

func writeToFile(path: String, contents: Data) throws {
    let file: FileHandle? = FileHandle(forWritingAtPath: path)
    file?.write(contents)
}
func writeToIndex(vaultPath: String, what: String) throws {
    do {
        try writeToFile(path: vaultPath+"/"+indexName, contents: what.data(using: String.Encoding.utf8)!)
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
func readFile(path: String) throws -> Data {
    do {
        return try Data(contentsOf: URL.init(fileURLWithPath: path))
    } catch let error as NSError {
        print("Could not read file! Reason: \(error)")
        throw FileErrors.genericError
    }
}
