//
//  Files.swift
//  
//
//  Created by Asaf Niv on 01/01/2020.
//

import Foundation
func writeToFile(path: String, contents: String) {
    print("Writing to:", path)
    let data = contents.data(using: String.Encoding.ascii)!
    let file = (path as NSString).expandingTildeInPath
    do {
        try data.write(to: URL.init(fileURLWithPath: file))
    } catch  {
        print("Could not write index!")
    }
}
func writeToIndex(vaultPath: String, what: String) {
    writeToFile(path: vaultPath+"/"+indexName, contents: what)
}