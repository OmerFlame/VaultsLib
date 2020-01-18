//
//  VaultAccess.swift
//  
//
//  Created by Asaf Niv on 16/01/2020.
//

import Foundation
import AES256CBC
let mbsize = 1048576
let blocksize = 64*mbsize
public class VaultAccess {
    public static func addFile(pathToAdd: String, vaultPath: String, pathInVault: String, pass: String) {
        // TODO: UUID parser should kick in
        let fileToAdd = FileHandle.init(forUpdatingAtPath: pathToAdd)
        FileManager.default.createFile(atPath: vaultPath+"/"+pathInVault, contents: nil, attributes: nil)
        let fileToWrite = FileHandle.init(forWritingAtPath: vaultPath+"/"+pathInVault)
        let fileSize = getFileSize(url: pathToAdd)
        var i: UInt64 = 0
        while fileSize > i {
            let block = fileToAdd?.readData(ofLength: blocksize)
            let encryptedBlock = encryptData(password: pass, message: block!)
            fileToWrite?.write(Data(bytes: encryptedBlock!, count: encryptedBlock!.count))
            fileToAdd?.seek(toFileOffset: fileToAdd!.offsetInFile+UInt64(blocksize))
            fileToWrite?.seekToEndOfFile()
            print("encrypted block")
            i += UInt64(blocksize)
        }
    }
    public static func getFile(vaultPath: String, pathInVault: String, pass: String) {
        let toDecrypt = vaultPath+"/"+pathInVault
        let fileToGet = FileHandle.init(forReadingAtPath: toDecrypt)
        FileManager.default.createFile(atPath: vaultPath+"/decrypted", contents: nil, attributes: nil)
        let testfile = FileHandle.init(forWritingAtPath: vaultPath+"/decrypted")
        var i: UInt64 = 0
        // Get file size of the encrypted file
        let fileSize = getFileSize(url: toDecrypt)
        while fileSize > i {
            let block = (fileToGet?.readData(ofLength: blocksize))!
            let decryptedBlock = decryptData(password: pass, message: block)
            testfile?.write(Data(bytes: decryptedBlock!, count: decryptedBlock!.count))
            testfile?.seekToEndOfFile()
            i += UInt64(blocksize)
        }
 }
        static func getFileSize(url: String)-> UInt64  {
            let fileUrl = URL(fileURLWithPath: url)
            let fileManager = FileManager.default
            do {
                let attributes = try fileManager.attributesOfItem(atPath: (fileUrl.path))
                var fileSize = attributes[FileAttributeKey.size] as! UInt64
                let dict = attributes as NSDictionary
                fileSize = dict.fileSize()
                return fileSize
            }
            catch let error as NSError {
                print("Something went wrong: \(error)")
                return 0
            }
        }
}
