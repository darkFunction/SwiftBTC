//
//  HexUtils.swift
//  SwiftBTC
//
//  Created by Sam Taylor on 10/04/2018.
//

import Foundation
import BigInt

public typealias Byte = UInt8

public func toByteArray<T>(_ value: T) -> [Byte] {
	var value = value
	return withUnsafeBytes(of: &value, { Array<Byte>($0) })
}

extension Collection where Iterator.Element == Byte {

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
	
	public var bigEndian: [Byte] {
		return CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderBigEndian.rawValue) ? Array(self) : self.reversed()
	}
	
	public var littleEndian: [Byte] {
		return CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderLittleEndian.rawValue) ? Array(self) : self.reversed()
	}
}


public struct HexadecimalString: ExpressibleByStringLiteral {
	let value: String
	
	public init(stringLiteral value: StringLiteralType) {
		self.value = value
	}
	
	public var toByteArray: [Byte] {
		let padded = value.count % 2 == 0 ? value : "0".appending(value)
		let hex = Array(padded)
		return stride(from: 0, to: value.count, by: 2).compactMap {
			Byte(String(hex[$0..<$0.advanced(by: 2)]), radix: 16)
		}
	}
}

public struct IPv6Address: ExpressibleByStringLiteral {
	let stringValue: String
	
	public init(stringLiteral value: StringLiteralType) {
		stringValue = value
	}
	
	public func isValid() -> Bool {
		return toByteArray != nil
	}
	
	public var toByteArray: [Byte]? {
		if let expanded = expanded {
			return getByteArray(from: expanded)
		}
		return nil
	}
	
	public var expanded: String? {
		let words = stringValue.split(separator: ":", omittingEmptySubsequences: false)
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
		
		if expanded.count < 39 {
			// Should be 39 (or more if ipv4 mapped)
			return nil
		}
		
		// IPv4 mapping
		
		// If first 80 bits (5 words) are zero we have an IPv4 address
		if expanded.split(separator: ":").reduce("", +).prefix(upTo: expanded.index(expanded.startIndex, offsetBy: 20)) == String(repeating: "0", count: 20) {
			let ipv4 = expanded.split(separator: ":").last
			if let ipv4Split = ipv4?.split(separator: ".").compactMap({ (decimalString) -> Byte? in
				return Byte(decimalString)
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
		return getByteArray(from: expanded) != nil ? expanded.lowercased() : nil
	}
	
	private func getByteArray(from: String) -> [Byte]? {
		let bytes = HexadecimalString(stringLiteral: from.split(separator: ":").reduce("", +)).toByteArray
		return bytes.count == 16 ? (CFByteOrderGetCurrent() == CFByteOrder(CFByteOrderLittleEndian.rawValue) ? bytes.reversed() : bytes) : nil
	}
}
