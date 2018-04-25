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
		XCTAssertEqual("000f:00ff:0fff:ffff:ffff:ffff:ffff:ffff", IPv6Address("f:ff:fff:ffff:ffff:ffff:ffff:ffff")?.expanded)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:0000", IPv6Address(":f:f:f:f:f:f:")?.expanded)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:000f", IPv6Address(":f:f:f:f:f:f:f")?.expanded)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:000f", IPv6Address(":f:f:f:f:f:f:f")?.expanded)
		XCTAssertEqual("0000:ffff:ffff:ffff:ffff:ffff:ffff:ffff", IPv6Address("0000:ffff:ffff:ffff:ffff:ffff:ffff:ffff")?.expanded)
		XCTAssertEqual("0000:ffff:0000:0000:0000:0000:ffff:ffff", IPv6Address("0000:ffff::ffff:ffff")?.expanded)
		XCTAssertEqual("2001:cdba:0000:0000:0000:0000:3257:9652", IPv6Address("2001:cdba:0:0:0:0:3257:9652")?.expanded)
		XCTAssertEqual("2001:cdba:0000:0000:0000:0000:3257:9652", IPv6Address("2001:cdba::3257:9652")?.expanded)
		XCTAssertEqual("0000:0000:0000:0000:0000:0000:0000:0000", IPv6Address("::")?.expanded)
		XCTAssertEqual(nil, 									  IPv6Address("0:::0")?.expanded)
		XCTAssertEqual("0000:0000:0000:0000:0000:ffff:7f00:0001", IPv6Address("::ffff:127.0.0.1")?.expanded)
		XCTAssertEqual(nil, 									  IPv6Address("0:0")?.expanded)
		XCTAssertEqual(nil, 									  IPv6Address("gggg:zzzz:0000:ffff:0000:0000:0000:0000")?.expanded)
	}
	
	func testIPv6ToByteArray() {
		XCTAssertEqual([Byte](repeating: 0, count: 16), IPv6Address("::" )?.byteArray)
		XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0] as [Byte], IPv6Address("ff::" )?.byteArray)
		
	}
}
