//
//  HexUtils.swift
//  SwiftBTC
//
//  Created by Sam Taylor on 10/04/2018.
//

import Foundation
import BigInt


extension Collection where Iterator.Element == UInt8 {

	public var hexadecimalString: String {
		return map { String(format: "%02X", $0) }.joined()
	}
	
	public var data: Data {
		return Data(bytes: Array(self))
	}
	
	public var base58String: String {
		return baseEncode(alphabet: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
	}
	
	public func baseEncode(alphabet: String) -> String {
		var decimal = BigUInt.init(self.data)
		let base = BigUInt(alphabet.count)
		var output = ""
		while decimal > 0 {
			let remainder = Int(decimal % base)
			decimal /= base
			output += String(alphabet[alphabet.index(alphabet.startIndex, offsetBy: remainder)])
		}
		return String(output.reversed())
	}
}

extension String {
	
	public var hexadecimalToByteArray: [UInt8] {
		let padded = self.count % 2 == 0 ? self : "0".appending(self)
		let hex = Array(padded)
		return stride(from: 0, to: count, by: 2).compactMap {
			UInt8(String(hex[$0..<$0.advanced(by: 2)]), radix: 16)
		}
	}
}
