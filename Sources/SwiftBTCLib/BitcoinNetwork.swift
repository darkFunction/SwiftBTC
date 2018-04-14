//
//  BitcoinNetwork.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 13/04/2018.
//

import CFNetwork

extension Array {
	var random: Element {
		return self[Int(arc4random_uniform(UInt32(self.count)))]
	}
}

private let seeds = [
	"seed.bitcoin.sipa.be",
	"dnsseed.bluematt.me",
	"dnsseed.bitcoin.dashjr.org",
	"seed.bitcoinstats.com",
	"seed.bitcoin.jonasschnelli.ch",
	"seed.btc.petertodd.org",
	"seed.bitcoin.sprovoost.nl"
]

public class BitcoinNetwork {
	
	public static func findNodes() {
		let hostent = gethostbyname(seeds.random)
		
		var i = 0
		var addresses = [String]()
		while (true) {
			if let p = hostent?.pointee.h_addr_list[i] {
				let cast = UnsafeRawPointer(p).assumingMemoryBound(to: in_addr.self)
				addresses.append(String(cString: inet_ntoa(cast.pointee)))
				i += 1
			} else {
				break
			}
		}
	}
	
}
