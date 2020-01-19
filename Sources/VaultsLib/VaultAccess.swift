//
//  VaultAccess.swift
//  
//
//  Created by Asaf Niv on 16/01/2020.
//

import Foundation
let mbsize = 1048576
let blocksize = 32*mbsize
let encryptedBlockLen = blocksize+metadataLen
public class VaultAccess {
    public static func addFile(pathToAdd: String, vaultPath: String, pathInVault: String, pass: String) {
        // TODO: UUID parser should kick in
        let fileToAdd = FileHandle.init(forReadingAtPath: pathToAdd) // Open a file handle for reading
        FileManager.default.createFile(atPath: vaultPath+"/"+pathInVault, contents: nil, attributes: nil) // Create the file we're going to write to
        let fileToWrite = FileHandle.init(forWritingAtPath: vaultPath+"/"+pathInVault) // Open a file handle for that file
        let fileSize = getFileSize(url: pathToAdd) // Get the file size of the file we're reading
        var i: UInt64 = 0 // Basically our current offset in the file we're reading
        while fileSize > i {
            // Iterate over blocks in the file
            fileToAdd?.seek(toFileOffset: i) // Move file pointer after the block we just read
            let block = fileToAdd?.readData(ofLength: blocksize) // Read 64MB from that file pointer
            let encryptedBlock = encryptData(password: pass, message: block!)
            fileToWrite?.write(Data(bytes: encryptedBlock!, count: encryptedBlock!.count)) // Write data to file
            fileToWrite?.seekToEndOfFile() // Move to the end of that file so we'll append to it and not overwrite anything
            print("encrypted block", i/UInt64(blocksize), "/", fileSize/UInt64(blocksize))
            i += UInt64(blocksize)
        }
        print("Added file")
        // close files
        fileToWrite?.closeFile()
        fileToAdd?.closeFile()
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
            fileToGet?.seek(toFileOffset: i) // Move to the correct location in the file
            let block = (fileToGet?.readData(ofLength: encryptedBlockLen))! // Read an encrypted block from it (bigger than normal block cuz metadata)
            let decryptedBlock = decryptData(password: pass, message: block) // Decrypt the encrypted block
            testfile?.write(Data(bytes: decryptedBlock!, count: decryptedBlock!.count))
            testfile?.seekToEndOfFile()
            i += UInt64(encryptedBlockLen)
            print("decrypted block")
        }
        print("Wrote test decrypted file")
        testfile?.closeFile()
        fileToGet?.closeFile()
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
