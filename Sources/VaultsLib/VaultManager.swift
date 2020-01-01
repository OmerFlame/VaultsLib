//
//  File.swift
//  
//
//  Created by Asaf Niv on 1/1/20.
//

import Foundation
public class VaultManager {
    func createVault(name: String, path: String, pass: String) {
        do
        {
            // TODO filter the name
            try FileManager.default.createDirectory(atPath: path+"/"+name, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            print("Unable to create directory \(error.debugDescription)")
        }
    }
}
