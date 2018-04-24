//
//  BitcoinNetwork.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 13/04/2018.
//

import CFNetwork
import Socket
import Foundation

private let seeds = [
	"seed.bitcoin.sipa.be",
	"dnsseed.bluematt.me",
	"dnsseed.bitcoin.dashjr.org",
	"seed.bitcoinstats.com",
	"seed.bitcoin.jonasschnelli.ch",
	"seed.btc.petertodd.org",
	"seed.bitcoin.sprovoost.nl"
]

public typealias Network = (port: Int, startString: HexadecimalString)
public struct Networks {
	public static let mainNet: Network = (port: 8333, startString: "0xf9beb4d9")
	public static let testNete: Network = (port: 18333, startString: "0x0b110907")
}

public enum NodeType: Int {
	case unknown = 0
	case full = 1
}

public class BitcoinNetwork {
	
	public static func randomSeedNode() -> String? {
		guard let seed = seeds.random else { return nil }
		
		let hostent = gethostbyname(seed)
		
		var i = 0
		var addresses = [String]()
		while true {
			if let p = hostent?.pointee.h_addr_list[i] {
				let cast = UnsafeRawPointer(p).assumingMemoryBound(to: in_addr.self)
				addresses.append(String(cString: inet_ntoa(cast.pointee)))
				i += 1
			} else {
				break
			}
		}
		
		return addresses.random
	}
	
	public static func connectToPeer(address: String, network: Network  = Networks.mainNet) throws {
		
		let socket = try Socket.create()
		try socket.connect(to: address, port: Int32(network.port))
	
		struct MessageHeader {
			let network: Network
			let commandName: String
			let payloadSize: UInt32
			let checkSum: [Byte]

			func pack() -> [Byte]? {
				guard checkSum.count == 4 else { return nil }
				guard commandName.count <= 12 else { return nil }

				var packed = [Byte]()
				packed += network.startString.toByteArray.littleEndian
				packed += [UInt8](commandName.appending(String(repeating: "0", count: 12 - commandName.count)).utf8).littleEndian
				packed += toByteArray(payloadSize).littleEndian
				packed += checkSum.littleEndian
				return packed
			}
		}
		
		struct VersionMessage {
			let protocolVersion: Int32
			let localServices: NodeType
			let timeStamp: Date
			let remoteServices: NodeType
			let remoteAddress: IPv6Address
			let remotePort: Int
			let localAddress: IPv6Address
			let localPort: Int
			let nonce: UInt64
			let userAgent: String
			let startHeight: Int32
			let relay: Byte
			
			func pack() -> [Byte]? {
				guard let remoteAddressBytes = remoteAddress.toByteArray, let localAddressBytes = localAddress.toByteArray else {
					return nil
				}
				
				let userAgentBytes: [UInt8] = Array(userAgent.utf8)
				guard userAgentBytes.count < Byte.max else { return nil }

				var packed = [Byte]()

				packed += toByteArray(protocolVersion).littleEndian
				packed += toByteArray(UInt64(localServices.rawValue)).littleEndian
				packed += toByteArray(Int64(timeStamp.timeIntervalSince1970)).littleEndian
				packed += toByteArray(UInt64(remoteServices.rawValue)).littleEndian
				packed += remoteAddressBytes.bigEndian
				packed += toByteArray(UInt16(remotePort)).bigEndian
				packed += toByteArray(UInt64(localServices.rawValue)).littleEndian
				packed += localAddressBytes.bigEndian
				packed += toByteArray(UInt16(localPort)).bigEndian
				packed += toByteArray(UInt64(nonce)).littleEndian
				packed += [Byte(userAgentBytes.count)]
				packed += userAgentBytes
				packed += toByteArray(Int32(startHeight)).littleEndian
				packed += [relay]
				
				return packed
			}
		}
		
		if let message = VersionMessage(
			protocolVersion: 70015,
			localServices: .unknown,
			timeStamp: Date(),
			remoteServices: .full,
			remoteAddress: IPv6Address(stringLiteral: "::ffff:\(address)"),
			remotePort: network.port,
			localAddress: IPv6Address(stringLiteral: "::ffff:127.0.0.1"),
			localPort: network.port,
			nonce: 0,
			userAgent: "/darkFunction:0.0.1",
			startHeight: 519567,
			relay: 0).pack() {
		
			if let hash1 = BitcoinKey.sha256Hash(bytes: message) {
				if let hash2 = BitcoinKey.sha256Hash(bytes: hash1) {
					if let header = MessageHeader(
						network: Networks.mainNet,
						commandName: "version",
						payloadSize: UInt32(message.count),
						checkSum: Array(hash2.prefix(upTo: 4))).pack() {
		
						
					}
				}
			}
			
			
		}
		
	}

}


