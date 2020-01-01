//
//  File.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//

import Foundation
public class VaultManager {
    // path: where's the vault?
    // pass: your password
    func createVault(path: String, pass: String) {
        do
        {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
        }
        
    }
}
