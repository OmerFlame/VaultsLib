//
//  VaultManager.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//

import Foundation
import AES256CBC
import CryptoSwift
public class VaultManager {
    // path: where's the vault?
    // pass: your password
    public static func createVault(path: String, pass: String, indexContent: String) {
        do
        {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory: \(error.debugDescription)")
        }
        // Initialize the index file with the vault's name (TEST)
        let hashedPass = pass.sha256()
        let encryptedContent = AES256CBC.encryptString(indexContent, password: String(hashedPass.prefix(32)))
        writeToIndex(vaultPath: path, what: encryptedContent!)
    }
   
    public static func deleteVault(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            print("Unable to delete directory: \(error.debugDescription)")
        }
    }
    
    public static func readVaultIndex(vault: String) -> String {
        return readIndex(vaultName: vault)
    }
}
