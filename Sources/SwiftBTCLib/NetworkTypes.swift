//
//  NetworkTypes.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 25/04/2018.
//

import Foundation


public enum NodeType: Int {
	case unknown = 0
	case full = 1
}

public struct UserAgent {
	let bytes: [Byte]
	let stringValue: String
	
	init(_ value: String) {
		// Max length of UserAgent must be describable by a single byte (< 256)
		bytes = Array(([Byte](value.utf8)).prefix(Int(Byte.max)))
		stringValue = String(bytes: bytes, encoding: .utf8) ?? ""
	}
}

public protocol MessagePayload {
	var commandName: String { get }
	func pack() -> [Byte]
}

public struct Message {
	
	private struct MessageHeader {
		let startString: HexadecimalString
		let commandName: String
		let payloadSize: UInt32
		let checksum: [Byte]
		
		func pack() -> [Byte] {
			var packed = [Byte]()
			let commandMaxLength = 12
			
			packed += startString.toByteArray.littleEndian
			packed += [UInt8](commandName.prefix(commandMaxLength).appending(String(repeating: "\0", count: commandMaxLength - commandName.count)).utf8).littleEndian  // Command name is padded with null chars (\0)
			packed += toByteArray(payloadSize).littleEndian
			packed += checksum.prefix(upTo: 4)
			
			return packed
		}
	}

	private let header: MessageHeader
	private let payload: MessagePayload
	
	public let bytes: [Byte]
	
	init?(startString: HexadecimalString, payload: MessagePayload) {
		self.payload = payload
		let packedPayload = payload.pack()
		
		guard
			let hash1 = BitcoinKey.sha256Hash(bytes: packedPayload),
			let hash2 = BitcoinKey.sha256Hash(bytes: hash1) else {
				return nil
		}
		
		header = MessageHeader(
			startString: startString,
			commandName: payload.commandName,
			payloadSize: UInt32(packedPayload.count),
			checksum: hash2)
			
		bytes = header.pack() + packedPayload
	}
}

public struct VersionPayload: MessagePayload {
	public let commandName = "version"
	
	let protocolVersion: Int32
	let localServices: NodeType
	let timeStamp: Date
	let remoteServices: NodeType
	let remoteAddress: IPv6Address
	let remotePort: UInt16
	let localAddress: IPv6Address
	let localPort: UInt16
	let nonce: UInt64
	let userAgent: UserAgent
	let startHeight: Int32
	let relay: Byte
	
	public func pack() -> [Byte] {
		var packed = [Byte]()
		
		packed += toByteArray(protocolVersion).littleEndian
		packed += toByteArray(UInt64(localServices.rawValue)).littleEndian
		packed += toByteArray(Int64(timeStamp.timeIntervalSince1970)).littleEndian
		packed += toByteArray(UInt64(remoteServices.rawValue)).littleEndian
		packed += remoteAddress.byteArray.bigEndian
		packed += toByteArray(remotePort).bigEndian
		packed += toByteArray(UInt64(localServices.rawValue)).littleEndian
		packed += localAddress.byteArray.bigEndian
		packed += toByteArray(localPort).bigEndian
		packed += toByteArray(UInt64(nonce)).littleEndian
		packed += [Byte(userAgent.bytes.count)]
		packed += userAgent.bytes
		packed += toByteArray(Int32(startHeight)).littleEndian
		packed += [relay]
		
		return packed
	}
}
