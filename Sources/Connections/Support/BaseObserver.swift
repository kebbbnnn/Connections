//
//  File.swift
//  
//
//  Created by Kevin Ladan on 12/9/22.
//

import Foundation
import Contacts

open class BaseObserver: NSObject, ObservableObject {
    public var isAuthorized: Bool {
        CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    public let store = CNContactStore()
    
    public func requestAccessIfNeeded(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !self.isAuthorized else { return }
        
        self.store.requestAccess(for: .contacts) { success, error in
            OperationQueue.main.addOperation {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(success))
                }
            }
        }
    }
}
