//
//  Chacha20.swift
//
//
//  Created by Asaf Niv on 17/01/2020.
//

import Foundation
import CryptoSwift
func encryptData(password: String, message: Data) -> Array<UInt8>? {
    let iv = ChaCha20.randomIV(12)
    let encryptedData: Array<UInt8>
    do {
        try encryptedData = ChaCha20(key: VaultManager.makePassword(plaintextPass: password).bytes, iv: iv).encrypt(message.bytes)
        return iv+encryptedData
    } catch  {
        print("Failed to encrypt data")
    }
    return nil
}
func decryptData(password: String, message: Data) -> Array<UInt8>? {
    var iv: Array<UInt8> = []
    var messageNoIV: Array<UInt8> = []
    while iv.count < 12 {
        iv.append(message[iv.count])
    }
    while messageNoIV.count < message.count-12 {
        messageNoIV.append(message[12+messageNoIV.count])
    }
    let decryptedData: Array<UInt8>
    do {
        try decryptedData = ChaCha20(key: VaultManager.makePassword(plaintextPass: password).bytes, iv: iv).decrypt(messageNoIV)
        return decryptedData
    } catch  {
        print("Failed to decrypt data")
    }
    return nil
}
