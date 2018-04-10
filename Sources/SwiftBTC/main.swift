import Clibsecp256k1


func getPublicKey(from privateKey: [UInt8], compressed: Bool = false) -> [UInt8]? {
	guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
		return nil
	}
	
	var c_publicKey: secp256k1_pubkey = secp256k1_pubkey()
	
	let result = secp256k1_ec_pubkey_create(
		context,
		&c_publicKey,
		UnsafePointer<UInt8>(privateKey)
	)

	let keySize = compressed ? 33 : 65
	let output = UnsafeMutablePointer<UInt8>.allocate(capacity: keySize)
	let outputLen = UnsafeMutablePointer<Int>.allocate(capacity: 1)
	outputLen.initialize(to: keySize)
	secp256k1_ec_pubkey_serialize(context, output, outputLen, &c_publicKey, UInt32(compressed ? SECP256K1_EC_COMPRESSED : SECP256K1_EC_UNCOMPRESSED))
	secp256k1_context_destroy(context)

	let publicKey = (result == 1) ? [UInt8](UnsafeBufferPointer(start: output, count: 65)) : nil
	output.deallocate()
	outputLen.deallocate()
	return publicKey
}


let privateKey: String = "0000000000000000000000000000000000000000000000000feedb0bdeadbeef"

print("Private key: \(privateKey)\n")
if let publicKey = getPublicKey(from: privateKey.hexadecimalToByteArray) {
	print("Public key: \(publicKey.hexadecimalString)")
}
