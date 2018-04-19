//
//  NetworkTests.swift
//  SwiftBTCTests
//
//  Created by Sam Taylor on 18/04/2018.
//

import XCTest
import SwiftBTCLib

class NetworkTests: XCTestCase {
	
	func testIPv6Expansion() {
		XCTAssertEqual("000f:00ff:0fff:ffff:ffff:ffff:ffff:ffff", "f:ff:fff:ffff:ffff:ffff:ffff:ffff".ipv6AddressExpand)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:0000", ":f:f:f:f:f:f:".ipv6AddressExpand)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:000f", ":f:f:f:f:f:f:f".ipv6AddressExpand)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:000f", ":f:f:f:f:f:f:f".ipv6AddressExpand)
		XCTAssertEqual("0000:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "0000:ffff:ffff:ffff:ffff:ffff:ffff:ffff".ipv6AddressExpand)
		XCTAssertEqual("0000:ffff:0000:0000:0000:0000:ffff:ffff", "0000:ffff::ffff:ffff".ipv6AddressExpand)
		XCTAssertEqual("2001:cdba:0000:0000:0000:0000:3257:9652", "2001:cdba:0:0:0:0:3257:9652".ipv6AddressExpand)
		XCTAssertEqual("2001:cdba:0000:0000:0000:0000:3257:9652", "2001:cdba::3257:9652".ipv6AddressExpand)
		XCTAssertEqual("0000:0000:0000:0000:0000:0000:0000:0000", "::".ipv6AddressExpand)
		XCTAssertEqual(nil, "0:::0".ipv6AddressExpand)
		XCTAssertEqual("0000:0000:0000:0000:0000:ffff:7f00:0001", "::ffff:127.0.0.1".ipv6AddressExpand)
	}
	
	func testIPv6ToByteArray() {
		XCTAssertEqual([UInt8](repeating: 0, count: 16), "::".ipv6AddressToByteArray)
		XCTAssertEqual([0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] as [UInt8], "ff::".ipv6AddressToByteArray)
		
	}
}
