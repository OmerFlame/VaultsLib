//
//  Index.swift
//  
//
//  Created by Asaf Niv on 1/21/20.
//

import Foundation
func addUUIDToIndex(uuid: UUID, filename: String, vaultPath: String, vaultPass: String) {
    do {
        var index = try loadIndex(vaultPath: vaultPath, pass: vaultPass)
        index![uuid.uuidString] = filename
        writeIndex(vaultPath: vaultPath, index: index!, vaultPass: vaultPass)
    } catch {
        print("Failed to add UUID to index")
    }
}

func loadIndex(vaultPath: String, pass: String) throws -> Dictionary<String, String>? {
    do {
        let indexContent = try readFile(path: vaultPath+"/"+indexName)
        let decryptedIndex = decryptData(password: pass, message: indexContent)
        let jsonResult = try JSONSerialization.jsonObject(with: Data(bytes: decryptedIndex!, count: decryptedIndex!.count), options: .mutableLeaves) as? Dictionary<String, String>
        return jsonResult
    } catch {
        print("Failed to read index")
        throw FileErrors.indexError
    }
}

func writeIndex(vaultPath: String, index: Dictionary<String, String>, vaultPass: String) {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: index, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
        let encryptedContent = encryptData(password: makePassword(plaintextPass: vaultPass), message: jsonString.data(using: .utf8)!)
        try writeToFile(path: vaultPath+"/"+indexName, contents: Data(bytes: encryptedContent!, count: encryptedContent!.count))
    } catch {
        print("Failed to write index")
    }
}
