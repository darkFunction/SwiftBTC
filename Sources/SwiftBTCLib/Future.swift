//
//  Future.swift
//  SwiftBTCLib
//
//  Created by Sam Taylor on 01/05/2018.
//

import Foundation


public enum Result<T, E: Error> {
	case success(T)
	case fail(E)
}


public struct Future<T, E: Error> {
	public typealias Completion = (Result<T, E>) -> ()
	public typealias AsyncOperation = (@escaping Completion) -> ()
	
	private let operation: AsyncOperation
	
	public init(_ operation: @escaping AsyncOperation) {
		self.operation = operation
	}
	
	public func start(completion: @escaping Completion) {
		self.operation(completion)
	}
	
	public func map<U>(_ transform: @escaping (T) -> U) -> Future<U, E> {
		return Future<U, E>() { completion in
			self.start() { result in
				switch result {
				case .success(let value):
					completion(.success(transform(value)))
				case .fail(let error):
					completion(.fail(error))
				}
			}
		}
	}
	
	public func flatMap<U>(_ transform: @escaping (T) -> Future<U, E>) -> Future<U, E> {
		return Future<U, E>() { completion in
			self.start() { result in
				switch result {
				case .success(let value):
					transform(value).start() { result in
						completion(result)
					}
				case .fail(let error):
					completion(.fail(error))
				}
			}
		}
		
	}
}

public extension Future {
	public func then<U>(_ transform: @escaping (T) -> Future<U, E>) -> Future<U, E> {
		return flatMap(transform)
	}
}
