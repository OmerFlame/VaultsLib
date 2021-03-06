//
//  Chacha20.swift
//
//
//  Created by Asaf Niv on 17/01/2020.
//  Copyright © 2020 Asaf Niv. All rights reserved.

import Foundation
import CryptoSwift
let authHeaderLen = 64
let ivLen = 12
let tagLen = 16
let metadataLen = authHeaderLen+ivLen+tagLen
public enum cryptoErrors: Error {
    case invalidData
    case decryptError
}

/**
 Encrypts given data.
 
 - Parameters:
    - password: The password to encrypt the data with
    - message: The data to encrypt
 
 - returns: If successful, returns an Array, includes the init vector + auth header + tag + encrypted data (in this order) as an encrypted block. If failed, returns `nil`
 */
func encryptData(password: String, message: Data) -> Array<UInt8>? {
    let iv = ChaCha20.randomIV(ivLen) // Make a random IV
    do {
        let authHeader = randomAuthHeader() // Random auth header for Poly1305 (verification)
        let (encryptedData, tag) = try AEADChaCha20Poly1305.encrypt(message.bytes, key: makePassword(plaintextPass: password).bytes, iv: iv, authenticationHeader: authHeader)
        return iv+authHeader+tag+encryptedData // Encrypted block structure, authHeader and tag are needed to verify our data
    } catch  {
        print("Failed to encrypt data")
    }
    return nil
}

/**
 Decrypts given data.
 
 - Parameters:
    - password: The password to decrypt the data with
    - message: The data to decrypt
 
 - throws: An error of type `decryptError`
 
 - returns: If successful, returns the decrypted data. If failed, returns `nil`
 
 */
func decryptData(password: String, message: Data) throws -> Array<UInt8>? {
    var iv: Array<UInt8> = []
    var ciphertext: Array<UInt8> = []
    var authHeader: Array<UInt8> = []
    var tag: Array<UInt8> = []
    // Extract IV, first 12 bytes
    while iv.count < ivLen {
        iv.append(message[iv.count])
    }
    // Extract authHeader, 64 bytes after the IV
    while authHeader.count < authHeaderLen {
        authHeader.append(message[authHeader.count+ivLen])
    }
    // Extract tag, 16 bytes after the authHeader
    while tag.count < tagLen {
        tag.append(message[ivLen+authHeaderLen+tag.count])
    }
    // Finally filter out ALL metadata and extract encryptedData (got returned from encryptData)
    while ciphertext.count < message.count-metadataLen {
        ciphertext.append(message[ivLen+tagLen+authHeaderLen+ciphertext.count])
    }
    do {
        // Decrypt it
        var (decryptedData, success) = try AEADChaCha20Poly1305.decrypt(ciphertext, key: makePassword(plaintextPass: password).bytes, iv: iv, authenticationHeader: authHeader, authenticationTag: tag)
        if !success { // If it failed, data was modified
            decryptedData = []
            print("either nsa modified this data or your storage is fucked")
            return nil
        }
        return decryptedData
    } catch {
        print("Failed to decrypt data")
        throw cryptoErrors.decryptError
    }
    //return nil
}

/**
 Generates a random auth header.
 
 - returns: A random auth header
 */
func randomAuthHeader() -> Array<UInt8> {
    var header: Array<UInt8> = []
    while header.count < authHeaderLen {
        header.append(UInt8.random(in: UInt8.min...UInt8.max))
    }
    return header
}

/**
 Derives a 32-byte key.
 
 - Parameters:
    - plaintextPass: The password to derive the key from.
 
 - Returns: If the given password is shorter or longer than 32 bytes, then returns a SHA256-derived key. If the given password is 32 bytes long, then it is returned as-is.
 */
func makePassword(plaintextPass: String) -> String {
    if plaintextPass.count < 32 {
        // TODO: find a better solution
        let hashedPass = plaintextPass.sha256()
        let finalPass = String(hashedPass.prefix(32))
        return finalPass
    } else if plaintextPass.count > 32 {
        let finalPass = String(plaintextPass.prefix(32))
        return finalPass
    } else {
        // Password is 32 chars
        return plaintextPass
    }
}
