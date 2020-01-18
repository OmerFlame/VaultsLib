//
//  Chacha20.swift
//
//
//  Created by Asaf Niv on 17/01/2020.
//

import Foundation
import CryptoSwift
let authHeaderLen = 64
let ivLen = 12
let tagLen = 16
let metadataLen = authHeaderLen+ivLen+tagLen
func encryptData(password: String, message: Data) -> Array<UInt8>? {
    let iv = ChaCha20.randomIV(ivLen)
    do {
        let authHeader = randomAuthHeader()
        let (encryptedData, tag) = try AEADChaCha20Poly1305.encrypt(message.bytes, key: makePassword(plaintextPass: password).bytes, iv: iv, authenticationHeader: authHeader)
        return iv+authHeader+tag+encryptedData
    } catch  {
        print("Failed to encrypt data")
    }
    return nil
}
func decryptData(password: String, message: Data) -> Array<UInt8>? {
    var iv: Array<UInt8> = []
    var ciphertext: Array<UInt8> = []
    var authHeader: Array<UInt8> = []
    var tag: Array<UInt8> = []
    while iv.count < ivLen {
        iv.append(message[iv.count])
    }
    while authHeader.count < authHeaderLen {
        authHeader.append(message[authHeader.count+ivLen])
    }
    while tag.count < tagLen {
        tag.append(message[ivLen+authHeaderLen+tag.count])
    }
    while ciphertext.count < message.count-ivLen-tagLen-authHeaderLen {
        ciphertext.append(message[ivLen+tagLen+authHeaderLen+ciphertext.count])
    }
    do {
        var (decryptedData, success) = try AEADChaCha20Poly1305.decrypt(ciphertext, key: makePassword(plaintextPass: password).bytes, iv: iv, authenticationHeader: authHeader, authenticationTag: tag)
        if !success {
            decryptedData = []
            print("either nsa modified this data or your storage is fucked")
            return nil
        }
        return decryptedData
    } catch  {
        print("Failed to decrypt data")
    }
    return nil
}

func randomAuthHeader() -> Array<UInt8> {
    var header: Array<UInt8> = []
    while header.count < authHeaderLen {
        header.append(UInt8.random(in: UInt8.min..<UInt8.max))
    }
    return header
}
