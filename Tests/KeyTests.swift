import XCTest
import SwiftBTCLib

class KeyTests: XCTestCase {
	
	func testPublicKeyGen() {
		let privateKey = "0000000000000000000000000000000000000000000000000feedb0bdeadbeef".hexadecimalToByteArray
		let publicKey = BitcoinKey.publicKey(from: privateKey)
		XCTAssertNotNil(publicKey)
		if let publicKey = publicKey {
			XCTAssertEqual(publicKey.hexadecimalString, "04d077e18fd45c031e0d256d75dfa8c3c21c589a861c4c33b99e64cf613113fcff9fc9d90a9d81346bcac64d3c01e6e0ef0828543edad73c0e257b845812cc8d28".uppercased())
		}
	}
	
	func testSha256Hash() {
		func hash(_ string: String) -> String? {
			return BitcoinKey.sha256Hash(bytes: [UInt8](string.utf8))?.hexadecimalString
		}
		XCTAssertEqual(hash("hello"), "2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824")
		XCTAssertEqual(hash("is there anybody out there?"), "38CC69C9F6F7C90510BD60F6C3D069C2BFD8491A0A6B27B3AEB45C240E60A23F")
	}
	
	func testBaseEncoding() {
		let hexAlphabet = "0123456789abcdef"
		XCTAssertEqual("abc123", "abc123".hexadecimalToByteArray.baseEncode(alphabet: hexAlphabet))
		XCTAssertEqual("ff0f0f", "ff0f0f".hexadecimalToByteArray.baseEncode(alphabet: hexAlphabet))
		XCTAssertEqual("123", "123".hexadecimalToByteArray.baseEncode(alphabet: hexAlphabet))
		XCTAssertEqual("ffffffffffffffffffffffffff0000000000000000", "ffffffffffffffffffffffffff0000000000000000".hexadecimalToByteArray.baseEncode(alphabet: hexAlphabet))
	}
	
	func testPublicKeyGeneration() {
		XCTAssertEqual(BitcoinKey.generateBitcoinAddress(from: "B06D0ACBD89B1ACB721416F708B6A367C0EF74660C26BB1D9B250146FE7E97CC".hexadecimalToByteArray),
					   "12uvDDYE4cJpbjkMkBZvY2vzgfgUjyGUpG")
		XCTAssertEqual(BitcoinKey.generateBitcoinAddress(from: "3998BA4119D43A89452259756CD14C20A445F04D49186EC2628BF745A361EEC5".hexadecimalToByteArray),
					   "1GCnMzpPvjBXrw7c5FrWmtCPP6ZcmGVZza")
	}
}
