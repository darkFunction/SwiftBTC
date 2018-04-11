import XCTest
import SwiftBTCLib

class KeyTests: XCTestCase {
	
	func testPublicKeyGen() {
		let privateKey = "0000000000000000000000000000000000000000000000000feedb0bdeadbeef".hexadecimalToByteArray
		let publicKey = BitcoinKey.getPublicKey(from: privateKey)
		XCTAssertNotNil(publicKey)
		if let publicKey = publicKey {
			XCTAssertEqual(publicKey.hexadecimalString, "04d077e18fd45c031e0d256d75dfa8c3c21c589a861c4c33b99e64cf613113fcff9fc9d90a9d81346bcac64d3c01e6e0ef0828543edad73c0e257b845812cc8d28".uppercased())
		}
	}
	
	func testSha256Hash() {
		func hash(_ string: String) -> String {
			return BitcoinKey.sha256Hash(bytes: [UInt8](string.utf8)).hexadecimalString
		}
		XCTAssertEqual(hash("hello"), "2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824")
		XCTAssertEqual(hash("is there anybody out there?"), "38CC69C9F6F7C90510BD60F6C3D069C2BFD8491A0A6B27B3AEB45C240E60A23F")
	}
	
	func testRipemd160() {
		// Can compare using openssl from commandline: `echo "<publicKey>" | xxd -r -p | openssl rmd160`
		
	}
}