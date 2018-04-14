import Clibsecp256k1
import CommonCrypto
import Foundation
import SwiftRIPEMD160

public class BitcoinKey {
	
	public static func publicKey(from privateKey: [UInt8], compressed: Bool = false) -> [UInt8]? {
		// Create signing context
		guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
			return nil
		}
		
		// Create public key from private key
		var c_publicKey: secp256k1_pubkey = secp256k1_pubkey()
		let result = secp256k1_ec_pubkey_create(
			context,
			&c_publicKey,
			UnsafePointer<UInt8>(privateKey)
		)
		defer {
			secp256k1_context_destroy(context)
		}

		// Serialise public key data into byte array (see header docs for secp256k1_pubkey)
		let keySize = compressed ? 33 : 65
		let output = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)
		let outputLen = UnsafeMutablePointer<Int>.allocate(capacity: 1)
		defer {
			output.deallocate()
			outputLen.deallocate()
		}
		outputLen.initialize(to: keySize)
		secp256k1_ec_pubkey_serialize(context, output, outputLen, &c_publicKey, UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
		let publicKey = (result == 1) ? [UInt8](UnsafeBufferPointer(start: output, count: keySize)) : nil
		
		
		
		return publicKey
	}
	
	public static func sha256Hash(bytes: [UInt8]) -> [UInt8]? {
		var data = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeMutableBytes { c_hash in
			_ = CC_SHA256(UnsafeRawPointer(bytes), UInt32(bytes.count), c_hash)
		}
		return [UInt8](data)
	}
	
	// https://en.bitcoin.it/wiki/Base58Check_encoding
	public static func base58CheckEncode(bytes: [UInt8]) -> String? {
		// Version 0 (public key hash)
		let version: [UInt8] = [0]

		func countLeadingZeroes(_ byteArray: [UInt8]) -> Int {
			return byteArray.reduce(0, { (acc, element) in
				return acc + (element == 0 ? 1 : 0)
			})
		}
		
		if let hash = sha256Hash(bytes: version + bytes) {
			// Hash the hash. Only uses first 4 chars as checksum
			if let checksum = sha256Hash(bytes: hash)?.prefix(upTo: 4) {
				let checksumBytes = [UInt8](checksum)
				let address = (version + bytes + checksumBytes).base58String
				return String(Array(repeating: "1", count: countLeadingZeroes(version + bytes)))
					+ address
			}
		}
		return nil
	}
	
	public static func ripemd160Hash(bytes: [UInt8]) -> [UInt8] {
		return [UInt8](RIPEMD160.hash(message: Data(bytes: bytes)))
	}
	
	public static func generateBitcoinAddress(from privateKey: [UInt8]) -> String? {
		
		// First we use secp256k1 algorithm to do the elliptic curve math for getting the (uncompressed) public key from the private key
		guard let pubKey = publicKey(from: privateKey) else { return nil }
		
		// Then we generate the sha256 hash of the public key
		guard let sha256 = sha256Hash(bytes: pubKey) else { return nil }

		// Shorten this hash using another hash function: ripemd160
		let address = ripemd160Hash(bytes: sha256)
		
		// Add version, checksum, and encode in base 58
		return base58CheckEncode(bytes: address)
	}
}
