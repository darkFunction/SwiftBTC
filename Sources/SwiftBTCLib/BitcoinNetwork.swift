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

public struct Networks {
	public static let mainNet: Network = (port: 8333, startString: "0xf9beb4d9")
	public static let testNete: Network = (port: 18333, startString: "0x0b110907")
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
	
	public static func connectToPeer(address: String, network: Network = Networks.mainNet) throws {
		
		let socket = try Socket.create()
		try socket.connect(to: address, port: Int32(network.port))
	
		guard let remoteAddress = IPv6Address("::ffff:\(address)"), let localAddress = IPv6Address("::ffff:127.0.0.1") else { return }
		
		let versionPayload = VersionPayload(
			protocolVersion: 70015,
			localServices: .unknown,
			timeStamp: Date(),
			remoteServices: .full,
			remoteAddress: remoteAddress,
			remotePort: network.port,
			localAddress: localAddress,
			localPort: network.port,
			nonce: 0,
			userAgent: UserAgent("/darkFunction:0.0.1"),
			startHeight: 519567,
			relay: 0)
			
		let message = Message(network: network, payload: versionPayload)
		
		// Send message
		
	}

}


