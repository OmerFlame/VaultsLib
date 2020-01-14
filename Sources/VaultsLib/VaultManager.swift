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
    
    public static func createVault(path: String, pass: String, indexContent: String) throws {
        do
        {
            // Initialize the index file with the encrypted vault's name
            let hashedPass = pass.sha256()
            let encryptedContent = AES256CBC.encryptString(indexContent, password: String(hashedPass.prefix(32)))
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
    
    public static func readVaultIndex(vault: String) -> String {
        do {
            return try readIndex(vaultName: vault)
        } catch let error as NSError {
            print("COULD NOT READ VAULT INDEX: \(error.debugDescription)")
            return error.debugDescription
        }

    }
    
    public static func encryptVault(vaultName: String) throws {
        let encryptedVaultPass = encryptPassword(plaintextPass: currentPass)
        let indexContents = readVaultIndex(vault: vaultName)
        do {
            let contentsToWrite = AES256CBC.encryptString(indexContents, password: encryptedVaultPass)
            try writeToIndex(vaultPath: dir + "/" + vaultName, what: contentsToWrite!)
        } catch let error as NSError {
            print("COULD NOT ENCRYPT VAULT: \(error.debugDescription)")
        }
    }
    
    public static func decryptVault(vaultName: String, plaintextPass: String) throws {
        currentPass = plaintextPass
        
        let encryptedVaultPass = encryptPassword(plaintextPass: currentPass)
        let indexContents = readVaultIndex(vault: vaultName)
        let contentsToWrite = AES256CBC.decryptString(indexContents, password: encryptedVaultPass)
        if (contentsToWrite == nil) {
            print("not writing nil")
            throw VaultManagerErrors.incorrectPassword
        }
        do {
            try writeToIndex(vaultPath: dir + "/" + vaultName, what: contentsToWrite!)
        } catch let error as NSError {
            print("COULD NOT DECRYPT THE VAULT: \(error.debugDescription)")
            throw VaultManagerErrors.genericError(errorDetails: error.debugDescription)
        }
    }
}
