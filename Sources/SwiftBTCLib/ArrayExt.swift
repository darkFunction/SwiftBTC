//
//  ArrayExt.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 16/04/2018.
//

import Foundation

extension Array {
	var random: Element? {
		return count > 0 ? self[Int(arc4random_uniform(UInt32(count)))] : nil
	}
}
