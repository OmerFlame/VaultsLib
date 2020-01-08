//
//  VaultManager.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//

import Foundation
public class VaultManager {
    // path: where's the vault?
    // pass: your password
    public static func createVault(path: String, pass: String) {
        do
        {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory: \(error.debugDescription)")
        }
        // Literally write null to generate our index
        writeToIndex(vaultPath: path, what: "")
    }
   
    public static func deleteVault(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            print("Unable to delete directory: \(error.debugDescription)")
        }
    }
}
