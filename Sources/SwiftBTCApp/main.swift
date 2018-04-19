import SwiftBTCLib

if let address = BitcoinNetwork.randomSeedNode() {
	try BitcoinNetwork.connectToPeer(address: address)
}
