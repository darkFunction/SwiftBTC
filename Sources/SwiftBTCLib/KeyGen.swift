import Clibsecp256k1
import CommonCrypto
import Foundation

public class BitcoinKey {
	
	public static func generatePrivateKey() -> [UInt8]? {
		return nil
	}

	public static func getPublicKey(from privateKey: [UInt8], compressed: Bool = false) -> [UInt8]? {
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

		// Serialise public key data into byte array (see header docs for secp256k1_pubkey)
		let keySize = compressed ? 33 : 65
		let output = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)
		let outputLen = UnsafeMutablePointer<Int>.allocate(capacity: 1)
		outputLen.initialize(to: keySize)
		secp256k1_ec_pubkey_serialize(context, output, outputLen, &c_publicKey, UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
		let publicKey = (result == 1) ? [UInt8](UnsafeBufferPointer(start: output, count: keySize)) : nil
		
		// Clean up
		secp256k1_context_destroy(context)
		output.deallocate()
		outputLen.deallocate()
		
		return publicKey
	}
	
	public static func sha256Hash(bytes: [UInt8]) -> [UInt8] {
		var data = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
		data.withUnsafeMutableBytes { c_hash in
			_ = CC_SHA256(UnsafeRawPointer(bytes), UInt32(bytes.count), c_hash)
		}
		return [UInt8](data)
	}
}
