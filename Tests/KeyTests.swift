import XCTest
import SwiftBTCLib

class KeyTests: XCTestCase {
	
	func testPublicKeyGen() {
		let privateKey = "0000000000000000000000000000000000000000000000000feedb0bdeadbeef".hexadecimalToByteArray
		if let publicKey = BitcoinKey.getPublicKey(from: privateKey) {
			XCTAssertEqual(publicKey.hexadecimalString, "04d077e18fd45c031e0d256d75dfa8c3c21c589a861c4c33b99e64cf613113fcff9fc9d90a9d81346bcac64d3c01e6e0ef0828543edad73c0e257b845812cc8d28".uppercased())
		}
	}
}
