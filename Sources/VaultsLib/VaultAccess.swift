//
//  VaultAccess.swift
//  
//
//  Created by Asaf Niv on 16/01/2020.
//  Copyright © 2020 Asaf Niv. All rights reserved.

import Foundation
let mbsize = 1048576
let blocksize = 32*mbsize
let encryptedBlockLen = blocksize+metadataLen
public class VaultAccess {
    public static func getIndex(vaultPath: String, pass: String) throws -> Dictionary<String, String>? {
        do {
            let index = try loadIndex(vaultPath: vaultPath, pass: pass)
            return index
        } catch {
            print("cannot load index for given vault path!")
            throw FileErrors.indexError
        }
    }
    
    // TODO: Deal with folders
    public static func addFile(plainTextName: String, pathToAdd: String, vaultPath: String, pathInVault: String, pass: String) -> Bool {
        let fileToAdd = FileHandle.init(forReadingAtPath: pathToAdd) // Open a file handle for reading
        let fileName = UUID() // Random file name
        FileManager.default.createFile(atPath: vaultPath+pathInVault+fileName.uuidString, contents: nil, attributes: nil) // Create the file we're going to write to
        let fileToWrite = FileHandle.init(forWritingAtPath: vaultPath+pathInVault+"/"+fileName.uuidString) // Open a file handle for that file
        let fileSize = getFileSize(path: pathToAdd) // Get the file size of the file we're reading
        var i: UInt64 = 0 // Basically our current offset in the file we're reading
        // Variables for the loop:
        var block = Data()
        var encryptedBlock: Array<UInt8> = []
        addUUIDToIndex(uuid: fileName, filename: plainTextName, vaultPath: vaultPath, vaultPass: pass)
        while fileSize! > i {
                // Iterate over blocks in the file
                fileToAdd?.seek(toFileOffset: i) // Move file pointer after the block we just read
                block = (fileToAdd?.readData(ofLength: blocksize))! // Read <blocksize> from that file pointer
                encryptedBlock = encryptData(password: pass, message: block)!
                fileToWrite?.write(Data(bytes: encryptedBlock, count: encryptedBlock.count)) // Write data to file
                fileToWrite?.seekToEndOfFile() // Move to the end of that file so we'll append to it and not overwrite anything
            print("encrypted block", i/UInt64(blocksize), "/", fileSize!/UInt64(blocksize))
            i += UInt64(blocksize)
        }
        print("Added file")
        // close files
        fileToWrite?.closeFile()
        fileToAdd?.closeFile()
        
        return true
    }
    
    public static func createDirectory(vaultPath: String, pathInVault: String, dirName: String, vaultPass: String) {
        let dirUUID = UUID()
        
        do {
            try FileManager.default.createDirectory(atPath: vaultPath+pathInVault+dirUUID.uuidString, withIntermediateDirectories: true, attributes: nil)
            addUUIDToIndex(uuid: dirUUID, filename: dirName, vaultPath: vaultPath, vaultPass: vaultPass)
            print("Created directory and added to index")
        } catch {
            print("Unable to create da shitty dir")
        }
    }
    // Get a file from the vault
    // vaultPath: yknow what
    // realPathInVault: the path in the vault, something like: a/b, not uuid/uuid
    public static func getFile(/*vaultPath: String,*/ /*pathInVault: String,*/atPath path: String, pass: String) throws -> Data {
        /*let index: Dictionary<String, String>?
        do {
            try index = loadIndex(vaultPath: vaultPath, pass: pass)
        } catch {
                throw cryptoErrors.invalidData
        }*/
        
        
        //let filename = index?.getKey(forValue: pathInVault)
        let toDecrypt = path
        let fileToGet = FileHandle.init(forReadingAtPath: toDecrypt)
        //FileManager.default.createFile(atPath: vaultPath+"/decrypted", contents: nil, attributes: nil)
        //let testfile = FileHandle.init(forWritingAtPath: vaultPath+"/decrypted")
        var i: UInt64 = 0
        // Get file size of the encrypted file
        let fileSize = getFileSize(path: toDecrypt)!
        var block: Data
        var decryptedBlock: Array<UInt8>
        var decryptedBlocks = [UInt8]()
        decryptedBlocks.reserveCapacity(Int(fileSize))
        while fileSize > i {
            fileToGet?.seek(toFileOffset: i) // Move to the correct location in the file
            block = (fileToGet?.readData(ofLength: encryptedBlockLen))! // Read an encrypted block from it (bigger than normal block cuz metadata)
            do {
                try decryptedBlock = decryptData(password: pass, message: block) ?? [0] // Decrypt the encrypted block
            } catch cryptoErrors.invalidData {
                throw cryptoErrors.invalidData
            }
            //testfile?.write(Data(bytes: decryptedBlock, count: decryptedBlock.count))
            //testfile?.seekToEndOfFile()
            decryptedBlocks += decryptedBlock
            i += UInt64(encryptedBlockLen)
            print("decrypted block")
        }
        print("Wrote test decrypted file")
        //testfile?.closeFile()
        fileToGet?.closeFile()
        
        let decryptedData = Data(decryptedBlocks)
        
        return decryptedData
    }
    
    public static func getChunkFromFile(atPath path: String, pass: String, offset: Int64, length: Int) throws -> Data {
        let toDecrypt = path
        let fileToGet = FileHandle.init(forReadingAtPath: toDecrypt)
        
        var block: Data
        var decryptedBlock: Array<UInt8>
        
        //fileToGet?.seek(toFileOffset: UInt64(offset) - UInt64(metadataLen))
        
        if offset == 0 {
            fileToGet?.seek(toFileOffset: 0)
        } else {
            //fileToGet?.seek(toFileOffset: UInt64(offset) - UInt64(metadataLen))
            fileToGet?.seek(toFileOffset: UInt64(offset))
        }
        
        block = (fileToGet?.readData(ofLength: encryptedBlockLen))!
        
        do {
            try decryptedBlock = decryptData(password: pass, message: block) ?? [0]
        } catch cryptoErrors.invalidData {
            throw cryptoErrors.invalidData
        }
        
        let decryptedData = Data(decryptedBlock)
        
        return decryptedData
    }
    
    public static func writeTempDecryptedFile(atPath path: String, pass: String, decryptedFilename: String) throws {
        let toDecrypt = path
        let fileToGet = FileHandle.init(forReadingAtPath: toDecrypt)
        FileManager.default.createFile(atPath: NSTemporaryDirectory() + decryptedFilename, contents: nil, attributes: nil)
        let decryptedFile = FileHandle.init(forWritingAtPath: NSTemporaryDirectory() + decryptedFilename)
        var i: UInt64 = 0
        let fileSize = getFileSize(path: toDecrypt)!
        var block: Data
        var decryptedBlock: Array<UInt8>
        while fileSize > i {
            fileToGet?.seek(toFileOffset: i)
            block = (fileToGet?.readData(ofLength: encryptedBlockLen))!
            do {
                try decryptedBlock = decryptData(password: pass, message: block) ?? [0]
            } catch cryptoErrors.invalidData {
                throw cryptoErrors.invalidData
            }
            decryptedFile?.write(Data(bytes: decryptedBlock, count: decryptedBlock.count))
            decryptedFile?.seekToEndOfFile()
            i += UInt64(encryptedBlockLen)
            print("decrypted block")
        }
        print("wrote temp decrypted file")
        fileToGet?.closeFile()
        decryptedFile?.closeFile()
    }
    
    public static func getFileSize(path: String)-> UInt64?  {
            do {
                let fileAttr = try FileManager.default.attributesOfItem(atPath: path)
                let fileSize = fileAttr[FileAttributeKey.size] as! UInt64
                return fileSize
            } catch {
                print("Failed to get file size!")
            }
            return nil
    }
    
    public static func isCorrectPassword(vaultPath: String, pass: String) -> Bool {
        do {
            try _ = loadIndex(vaultPath: vaultPath, pass: pass)
            return true
        } catch cryptoErrors.invalidData{
            return false
        } catch {
            return false
        }
    }
}

