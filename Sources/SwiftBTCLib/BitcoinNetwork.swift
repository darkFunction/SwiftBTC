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

public enum Port: Int {
	case mainNet = 8333
	case testNet = 18333
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
	
	public static func connectToPeer(address: String, port: Port = .mainNet) throws {
		
		let socket = try Socket.create()
		try socket.connect(to: address, port: Int32(port.rawValue))
		
		let version: Int32 = Int32(CFSwapInt32HostToLittle(0))
		let localServices: UInt64 = CFSwapInt64HostToLittle(UInt64(NodeType.unknown.rawValue))
		let timestamp: Int64 = Int64(CFSwapInt64HostToLittle(UInt64(Date().timeIntervalSince1970)))
		let remoteServices: UInt64 = CFSwapInt64HostToLittle(UInt64(NodeType.full.rawValue))
		let remoteAddress: [UInt8] = "::ffff:\(address)".withCString { (startByte) -> [UInt8] in // IPv4 mapped to IPv6
			var charArray = [UInt8](repeating: 0, count: 16)
			var i = 0
			while true && i < 16 {
				if startByte[i] == nil { break }
				charArray[i] = UInt8(startByte[i])
				i += 1
			}
			return charArray
		}
		
	}
	
}


