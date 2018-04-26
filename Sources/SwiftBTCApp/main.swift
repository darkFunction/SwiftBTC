import SwiftBTCLib

let network: Network = .testNet

if let address = BitcoinNetwork.randomSeedNode(network: network) {
	try BitcoinNetwork.connectToPeer(address: address, network: network)
}
