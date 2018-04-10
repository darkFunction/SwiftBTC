//
//  HexUtils.swift
//  SwiftBTC
//
//  Created by Sam Taylor on 10/04/2018.
//

import Foundation

extension Collection where Iterator.Element == UInt8 {

	var hexadecimalString: String {
		return map{ String(format: "%02X", $0) }.joined()
	}
}

extension String {
	
	var hexadecimalToByteArray: [UInt8] {
		assert(self.count % 2 == 0, "Expected string of even length (2 hex chars per byte)")
		let hex = Array(self)
		return stride(from: 0, to: count, by: 2).compactMap {
			UInt8(String(hex[$0..<$0.advanced(by: 2)]), radix: 16)
		}
	}
}
