//
//  AESEncryption.swift
//  Requests
//
//  Created by Francisco Javier García Gutiérrez on 2023/06/24.
//

import Foundation

struct AesEncryption {
    static func aesEncrypt(data: Data, keyData: Data) -> Data? {
        let clear = data
        let cryptLength = [UInt8](repeating: 0, count: clear.count + kCCBlockSizeAES128).count
        var crypt = Data(count: cryptLength)
        
        let keyLength   = size_t(kCCKeySizeAES256)
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = crypt.withUnsafeMutableBytes {cryptBytes in
            clear.withUnsafeBytes {clearBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            options,
                            keyBytes.baseAddress, keyLength,
                            nil,
                            clearBytes.baseAddress, clear.count,
                            cryptBytes.baseAddress, cryptLength,
                            &numBytesEncrypted)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            crypt.removeSubrange(numBytesEncrypted..<crypt.count)
        } else {
            return nil
        }
        
        return crypt
    }
    
    static func aesDecrypt(data: Data, keyData: Data) -> Data? {
        let crypt = data
        let clearLength = crypt.count
        var clear = Data(count: clearLength)
        
        let keyLength   = size_t(kCCKeySizeAES256)
        let options   = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesCleared :size_t = 0
        
        let cryptStatus = clear.withUnsafeMutableBytes {clearBytes in
            crypt.withUnsafeBytes {cryptBytes in
                keyData.withUnsafeBytes {keyBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES128),
                            options,
                            keyBytes.baseAddress, keyLength,
                            nil,
                            cryptBytes.baseAddress, crypt.count,
                            clearBytes.baseAddress, clearLength,
                            &numBytesCleared)
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            clear.removeSubrange(numBytesCleared..<clear.count)
        } else {
            return nil
        }
        
        return clear
    }
    
    static func generateEncryptionKey(password: String, salt: String) -> Data? {
        guard let passwordData = password.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            return nil
        }
        
        var derivedKeyData = Data(repeating: 0, count: kCCKeySizeAES128)
        let derivedKeyDataCount = derivedKeyData.count
        let derivationResult = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            passwordData.withUnsafeBytes { passwordBytes in
                saltData.withUnsafeBytes { saltBytes in
                    CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), passwordBytes.baseAddress, passwordData.count, saltBytes.baseAddress, saltData.count, CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), 10000, derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress, derivedKeyDataCount)
                }
            }
        }
        
        if (derivationResult != kCCSuccess) {
            print("Error: \(derivationResult)")
            return nil
        }
        
        return derivedKeyData
    }
}
