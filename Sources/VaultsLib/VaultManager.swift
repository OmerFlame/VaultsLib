//
//  VaultManager.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//

import Foundation
import AES256CBC
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
            // Initialize the index file with the encrypted vault's name
            let hashedPass = pass.sha256()
            let messageDictionary : [String: Any] = [:]
            let jsonData = try JSONSerialization.data(withJSONObject: messageDictionary, options: [])
            let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
            let encryptedContent = AES256CBC.encryptString(jsonString, password: String(hashedPass.prefix(32)))
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            try writeToIndex(vaultPath: path, what: encryptedContent!)
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
    
    public static func encryptPassword(plaintextPass: String) -> String {
        let hashedPass = plaintextPass.sha256()
        let finalPass = String(hashedPass.prefix(32))
        return finalPass
    }
    
    public static func readVaultIndex(vaultPath: String) -> String {
        do {
            return try readIndex(vaultPath: vaultPath)
        } catch let error as NSError {
            print("COULD NOT READ VAULT INDEX: \(error.debugDescription)")
            return error.debugDescription
        }

    }
    
    // burn this down
    /*
    public static func encryptVault(vaultName: String) throws {
        let encryptedVaultPass = encryptPassword(plaintextPass: currentPass)
        let indexContents = readVaultIndex(vaultPath: vaultName)
        do {
            let contentsToWrite = AES256CBC.encryptString(indexContents, password: encryptedVaultPass)
            try writeToIndex(vaultPath: dir + "/" + vaultName, what: contentsToWrite!)
        } catch let error as NSError {
            print("COULD NOT ENCRYPT VAULT: \(error.debugDescription)")
        }
    }
 */
    
    public static func decryptVaultIndex(vaultPath: String, plaintextPass: String) throws -> String {
        currentPass = plaintextPass
        let encryptedVaultPass = encryptPassword(plaintextPass: currentPass)
        let indexContents = readVaultIndex(vaultPath: vaultPath)
        let decryptedIndex = AES256CBC.decryptString(indexContents, password: encryptedVaultPass)
        if (decryptedIndex == nil) {
            print("hi nsa")
            throw VaultManagerErrors.incorrectPassword
        }
        return decryptedIndex!
    }
}
