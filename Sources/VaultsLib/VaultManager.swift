//
//  VaultManager.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//  Copyright © 2020 Asaf Niv. All rights reserved.

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
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw VaultManagerErrors.genericError(errorDetails: "Could not create vault")
        }
        let index : [String: String] = [:]
        writeIndex(vaultPath: path, index: index, vaultPass: pass)
    }
   
    public static func deleteVault(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            print("Unable to delete directory: \(error.debugDescription)")
        }
    }
    
}
