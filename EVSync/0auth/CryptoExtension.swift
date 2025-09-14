//
//  CryptoExtension.swift
//  Charge&Go
//
//  Created by Daulet Yerkinov on 12.09.25.
//

import Foundation
import CommonCrypto

extension Data {
    var sha256: String {
        let hash = self.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes.baseAddress, CC_LONG(self.count), &hash)
            return hash
        }
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
