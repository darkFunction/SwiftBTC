//
//  ArrayExt.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 16/04/2018.
//

import Foundation

extension Array {
	var random: Element? {
		guard count > 0 else { return nil }
		return self[Int(arc4random_uniform(UInt32(count)))]
	}
}
