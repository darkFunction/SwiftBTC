import SwiftBTCLib
import Foundation


func waitForNodeAddress(network: Network, timeout: TimeInterval) -> Node? {
	let semaphore = DispatchSemaphore(value: 0)
	var node: Node? = nil
	
	Node.random(network: .testNet).start() { (result) in
		switch result {
		case .success(let value):
			node = value
		case .fail(let e):
			print(e)
		}
		semaphore.signal()
	}
	
	_ = semaphore.wait(timeout: .now() + timeout)
	
	return node
}

guard let node = waitForNodeAddress(network: .testNet, timeout: 5) else { exit(1) }

let connection = Connection(node: node)

connection.connect()
	.then(connection.sendVersion)
	.start() { result in
		print(result)
}

dispatchMain()


