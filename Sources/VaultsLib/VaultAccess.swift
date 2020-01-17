//
//  VaultAccess.swift
//  
//
//  Created by Asaf Niv on 16/01/2020.
//

import Foundation
import AES256CBC
public class VaultAccess {
    public static func addFile(pathToAdd: String, vaultPath: String, pathInVault: String, pass: String) {
        var fileContents: Data
        do {
            try fileContents =
                readFile(path: pathToAdd)
            let encrypted = encryptData(password: pass, message: fileContents)
            // TODO: UUID parser should kick in
            let fileData = Data(bytes: encrypted!, count: encrypted!.count)
            try writeToFile(path: vaultPath+pathInVault, contents: (fileData))
        } catch {
            print("nope")
        }
    }
    public static func getFile(vaultPath: String, pathInVault: String, pass: String) {
           var fileContents: Data
           let decrypted: String
           do {
               try fileContents =
                   readFile(path: vaultPath+"/"+pathInVault)
            decrypted = AES256CBC.decryptString(String(decoding: fileContents, as: UTF8.self), password: pass)!
               // TODO: UUID parser should kick in
            try writeToFile(path: vaultPath+"/decrypted"+pathInVault, contents: (decrypted.data(using: String.Encoding.utf8)!))
           } catch {
               print("nope")
           }
       }
}
