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
		XCTAssertEqual("000f:00ff:0fff:ffff:ffff:ffff:ffff:ffff", ("f:ff:fff:ffff:ffff:ffff:ffff:ffff" as IPv6Address).expanded)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:0000", (":f:f:f:f:f:f:" as IPv6Address).expanded)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:000f", (":f:f:f:f:f:f:f" as IPv6Address).expanded)
		XCTAssertEqual("0000:000f:000f:000f:000f:000f:000f:000f", (":f:f:f:f:f:f:f" as IPv6Address).expanded)
		XCTAssertEqual("0000:ffff:ffff:ffff:ffff:ffff:ffff:ffff", ("0000:ffff:ffff:ffff:ffff:ffff:ffff:ffff" as IPv6Address).expanded)
		XCTAssertEqual("0000:ffff:0000:0000:0000:0000:ffff:ffff", ("0000:ffff::ffff:ffff" as IPv6Address).expanded)
		XCTAssertEqual("2001:cdba:0000:0000:0000:0000:3257:9652", ("2001:cdba:0:0:0:0:3257:9652" as IPv6Address).expanded)
		XCTAssertEqual("2001:cdba:0000:0000:0000:0000:3257:9652", ("2001:cdba::3257:9652" as IPv6Address).expanded)
		XCTAssertEqual("0000:0000:0000:0000:0000:0000:0000:0000", ("::" as IPv6Address).expanded)
		XCTAssertEqual(nil, 									  ("0:::0" as IPv6Address).expanded)
		XCTAssertEqual("0000:0000:0000:0000:0000:ffff:7f00:0001", ("::ffff:127.0.0.1" as IPv6Address).expanded)
		XCTAssertEqual(nil, 									  ("0:0" as IPv6Address).expanded)
		XCTAssertEqual(nil, 									  ("gggg:zzzz:0000:ffff:0000:0000:0000:0000" as IPv6Address).expanded)
	}
	
	func testIPv6ToByteArray() {
		XCTAssertEqual([Byte](repeating: 0, count: 16), ("::" as IPv6Address).toByteArray)
		XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0] as [Byte], ("ff::" as IPv6Address).toByteArray)
		
	}
}
