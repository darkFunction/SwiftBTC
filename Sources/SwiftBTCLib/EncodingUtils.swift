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
	
	public var ipv6AddressToByteArray: [UInt8]? {
		return ipv6AddressExpand?.split(separator: ":").reduce("", +).hexadecimalToByteArray
	}
	
	public var ipv6AddressExpand: String? {
		let words = split(separator: ":", omittingEmptySubsequences: false)
		var fillCount = 0
		// Pad each word with zeroes
		var expanded = words.enumerated().reduce("") { (result: String, item: (index: Int, word: Substring)) -> String in
			let acc = result + String(repeating: "0", count: max(0, 4 - item.word.count)).appending(item.word).appending(item.index < words.count - 1 ? ":" : "")
			if (item.word.count == 0 && item.index > 0 && item.index < words.count - 1) {
				// Found "::" so insert as many "0000" as required
				fillCount += 1
				return acc + String(repeating: "0000:", count: 8 - words.count)
			}
			return acc
		}
		if fillCount > 1 {
			// Found more than one instance of "::", address is invalid
			return nil
		}
	
		// IPv4 mapping
		
		// If first 80 bits (5 words) are zero we have an IPv4 address
		if expanded.split(separator: ":").reduce("", +).prefix(upTo: expanded.index(expanded.startIndex, offsetBy: 20)) == String(repeating: "0", count: 20) {
			let ipv4 = expanded.split(separator: ":").last
			if let ipv4Split = ipv4?.split(separator: ".").compactMap({ (decimalString) -> UInt8? in
				return UInt8(decimalString)
			}) {
				if ipv4Split.count == 4 {
					// Seems to be a valid IPv4
					var translated = String()
					ipv4Split.forEach { (decimalByte) in
						translated.append([decimalByte].hexadecimalString)
					}
					translated.insert(":", at: translated.index(translated.startIndex, offsetBy: 4))
					
					var split = expanded.split(separator: ":").map{ $0 + ":" }
					
					// Remove first if we performed a fill since we will have overfilled by 1 word
					if fillCount != 0 {
						split.removeFirst()
					}
					
					// Remove last chunk (ipv4 address) and replace with the translated ipv6 format
					split.removeLast()
					
					expanded = split.reduce("", +)
					
					// Add the translated address
					expanded += translated
				}
			}
		}
		
		// Sanity check length
		return expanded.count == 39 ? expanded.lowercased() : nil
	}

}
