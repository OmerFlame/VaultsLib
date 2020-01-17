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
        try encryptedData = ChaCha20(key: password.bytes.sha256(), iv: iv).encrypt(message.bytes)
        return iv+encryptedData
    } catch  {
        print("Failed to encrypt data")
    }
    return nil
}
