//
//  BitcoinNetwork.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 13/04/2018.
//

import CFNetwork
import Socket
import Foundation


public enum Network {
	case mainNet
	case testNet

	struct NetworkInfo {
		let port: UInt16
		let startString: HexadecimalString
		let seeds: [String]
	}
	
	var info: NetworkInfo {
		switch self {
		case .mainNet:
			return NetworkInfo(port: 8333, startString: "0xf9beb4d9", seeds:  [
				"seed.bitcoin.sipa.be",
				"dnsseed.bluematt.me",
				"dnsseed.bitcoin.dashjr.org",
				"seed.bitcoinstats.com",
				"seed.bitcoin.jonasschnelli.ch",
				"seed.btc.petertodd.org",
				"seed.bitcoin.sprovoost.nl"
			])
		case .testNet:
			return NetworkInfo(port: 18333, startString: "0x0b110907", seeds:  [
				"testnet-seed.bitcoin.jonasschnelli.ch",
				"seed.tbtc.petertodd.org",
				"seed.testnet.bitcoin.sprovoost.nl",
				"testnet-seed.bluematt.me"
			])
		}
	}
	
}

public class BitcoinNetwork {
	
	public static func randomSeedNode(network: Network = .mainNet) -> String? {
		guard let seed = network.info.seeds.random else { return nil }
		
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
	
	public static func connectToPeer(address: String, network: Network = .mainNet) throws {
		
		let socket = try Socket.create()
		try socket.connect(to: address, port: Int32(network.info.port))
		
		print("Connected to \(address)")
			
		defer {
			socket.close()
		}
		
		guard socket.isConnected else { return }
		guard let remoteAddress = IPv6Address("::ffff:\(address)"), let localAddress = IPv6Address("::ffff:127.0.0.1") else { return }
		
		let versionPayload = VersionPayload(
			protocolVersion: 70015,
			localServices: .unknown,
			timeStamp: Date(),
			remoteServices: .full,
			remoteAddress: remoteAddress,
			remotePort: network.info.port,
			localAddress: localAddress,
			localPort: network.info.port,
			nonce: 0,
			userAgent: UserAgent("/darkFunction:0.0.1"),
			startHeight: 519567,
			relay: 0)
			
		if let message = Message(startString: network.info.startString, payload: versionPayload) {
		
			var bytes = message.bytes
			try socket.write(from: &bytes, bufSize: bytes.count)

			var data = Data()
			try socket.read(into: &data)
			print(data)
		}
	}

}


