//
//  NetworkTypes.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 25/04/2018.
//

import Foundation

public typealias Network = (port: Int, startString: HexadecimalString)

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
		let network: Network
		let commandName: String
		let payloadSize: UInt32
		let checksum: [Byte]
		
		func pack() -> [Byte] {
			var packed = [Byte]()
			
			packed += network.startString.toByteArray.littleEndian
			packed += [UInt8](commandName.prefix(12).appending(String(repeating: "0", count: 12 - commandName.count)).utf8).littleEndian
			packed += toByteArray(payloadSize).littleEndian
			packed += checksum.prefix(upTo: 4)
			
			return packed
		}
	}

	private let header: MessageHeader
	private let payload: MessagePayload
	
	public let bytes: [Byte]
	
	init?(network: Network, payload: MessagePayload) {
		self.payload = payload
		let packedPayload = payload.pack()
		
		guard
			let hash1 = BitcoinKey.sha256Hash(bytes: packedPayload),
			let hash2 = BitcoinKey.sha256Hash(bytes: hash1) else {
				return nil
		}
		
		header = MessageHeader(
			network: network,
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
	let remotePort: Int
	let localAddress: IPv6Address
	let localPort: Int
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
		packed += toByteArray(UInt16(remotePort)).bigEndian
		packed += toByteArray(UInt64(localServices.rawValue)).littleEndian
		packed += localAddress.byteArray.bigEndian
		packed += toByteArray(UInt16(localPort)).bigEndian
		packed += toByteArray(UInt64(nonce)).littleEndian
		packed += [Byte(userAgent.bytes.count)]
		packed += userAgent.bytes
		packed += toByteArray(Int32(startHeight)).littleEndian
		packed += [relay]
		
		return packed
	}
}
