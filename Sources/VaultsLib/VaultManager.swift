//
//  VaultManager.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//

import Foundation
import CryptoSwift

public enum VaultManagerErrors: Error {
    case incorrectPassword
    case genericError(errorDetails: String)
}

public class VaultManager {
    // path: where's the vault?
    // pass: your password
    
    public static func createVault(path: String, pass: String) throws {
        do
        {
            let messageDictionary : [String: Any] = [:]
            let jsonData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            let encryptedContent = encryptData(password: makePassword(plaintextPass: pass), message: jsonString.data(using: .utf8)!)
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            try writeToIndex(vaultPath: path, what: Data(bytes: encryptedContent!, count: encryptedContent?.count ?? 0))
        } catch let error as VaultManagerErrors {
            print("COULD NOT CREATE VAULT: \(error.localizedDescription)")
            throw VaultManagerErrors.genericError(errorDetails: error.localizedDescription)
        } catch {
            print("fuck you error")
        }
    }
   
    public static func deleteVault(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            print("Unable to delete directory: \(error.debugDescription)")
        }
    }
    
}
func makePassword(plaintextPass: String) -> String {
    if plaintextPass.count < 32 {
        // TODO: find a better solution
        let hashedPass = plaintextPass.sha256()
        let finalPass = String(hashedPass.prefix(32))
        return finalPass
    } else if plaintextPass.count > 32 {
        let finalPass = String(plaintextPass.prefix(32))
        return finalPass
    } else {
        // Password is 32 chars
        return plaintextPass
    }
}
