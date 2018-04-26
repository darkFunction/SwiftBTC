//
//  BitcoinClient.swift
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

public enum NetworkError: Error {
	case noSeedsProvided
	case seedLookupFailed(seed: String)
	case socketIssue(message: String)
	case messageFormat(message: String)
}

public struct Node {
	let network: Network
	let address: IPv6Address
	
	public static func random(network: Network = .mainNet) -> Future<Node, NetworkError> {
		return Future() { completion in
		
			guard let seed = network.info.seeds.random else {
				completion(.fail(.noSeedsProvided))
				return
			}
			
			DispatchQueue.global(qos: .userInitiated).async {
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
				if let address = addresses.random, let ipv6Address = IPv6Address("::ffff:\(address)") {
					completion(.success(Node(network: network, address: ipv6Address)))
				} else {
					completion(.fail(.seedLookupFailed(seed: seed)))
				}
			}
		}
	}
}

public class Connection {
	
	let node: Node
	var socket: Socket? = nil
	
	public init(node: Node) {
		self.node = node
	}

	deinit {
		socket?.close()
	}
	
	public func connect() -> Future<Void, NetworkError> {
		
		let node = self.node
		
		return Future() { [weak self] completion in
			
			guard let strongSelf = self else { return }
			
			DispatchQueue.global(qos: .userInitiated).async {
				do {
					strongSelf.socket = try Socket.create(family: .inet6)
					try strongSelf.socket?.connect(to: node.address.stringValue, port: Int32(node.network.info.port))
					completion(.success(()))
				} catch {
					let message = (error as? Socket.Error)?.description ?? "Unexpected socket connection error"
					completion(.fail(NetworkError.socketIssue(message: message)))
				}
			}
		}
	}
	
	public func sendVersion() -> Future<Data, NetworkError> {
		
		let node  = self.node
		let socket = self.socket
		
		return Future() { completion in
		
			guard let socket = socket else {
				completion(.fail(NetworkError.socketIssue(message: "Socket not open")))
				return
			}
			
			let versionPayload = VersionPayload(
				protocolVersion: 70015,
				localServices: .unknown,
				timeStamp: Date(),
				remoteServices: .full,
				remoteAddress: node.address,
				remotePort: node.network.info.port,
				localAddress: IPv6Address("::ffff:127.0.0.1")!,
				localPort: node.network.info.port,
				nonce: 0,
				userAgent: UserAgent("/darkFunction:0.0.1"),
				startHeight: 519567,
				relay: 0)
			
			if let message = Message(startString: node.network.info.startString, payload: versionPayload) {
				var bytes = message.bytes
				var data = Data()
				
				do {
					try socket.write(from: &bytes, bufSize: bytes.count)
					_ = try socket.read(into: &data)
					completion(.success(data))
				} catch {
					let message = (error as? Socket.Error)?.description ?? "Unexpected socket connection error"
					completion(.fail(NetworkError.socketIssue(message: message)))
				}
			}
		}
	}
}


