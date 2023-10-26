//
//  FetchRequestPublisher.swift
//  Nos
//
//  Created by Matthew Lorentz on 10/26/23.
//

import Foundation
import Combine
import CoreData

/// Create by passing in a FetchedResultsController
/// This will perform the fetch request on the correct queue and publish the resutls on the
/// publishers.
/// source: https://gist.github.com/josephlord/0d6a9d0871bd2e1b3a3bdbf20c184f88
/// 
final public class FetchedResultsControllerPublisher<FetchType> where FetchType : NSFetchRequestResult {
    
    private let internalFRCP: FetchedResultsControllerPublisherInternal<FetchType>
    
    /// Pass in a configured fetchResults controller and this class will provide a choice of publishers
    /// for you depending on how you like your errors
    public init(fetchedResultsController: NSFetchedResultsController<FetchType>,
                performFetchNotRequired: Bool = false) {
        self.internalFRCP = FetchedResultsControllerPublisherInternal(
            fetchedResultsController: fetchedResultsController,
            performFetch: !performFetchNotRequired)
    }
    
    public lazy var publisherWithErrors: AnyPublisher<[FetchType], Error> = {
        return self.internalFRCP.publisher.eraseToAnyPublisher()
    }()
    public lazy var publisher: AnyPublisher<[FetchType], Never> = {
        return self.internalFRCP.publisher.replaceError(with: []).eraseToAnyPublisher()
    }()
}

final private class FetchedResultsControllerPublisherInternal<FetchType>
: NSObject, NSFetchedResultsControllerDelegate
where FetchType : NSFetchRequestResult {
    
    let publisher: PassthroughSubject<[FetchType], Error>
    let fetchedResultsController: NSFetchedResultsController<FetchType>
    init(fetchedResultsController: NSFetchedResultsController<FetchType>,
         performFetch: Bool) {
        self.fetchedResultsController = fetchedResultsController
        publisher = PassthroughSubject<[FetchType], Error>()
        super.init()
        fetchedResultsController.delegate = self
        fetchedResultsController.managedObjectContext.perform {
            do {
                if performFetch {
                    try fetchedResultsController.performFetch()
                }
                self.publisher.send(fetchedResultsController.fetchedObjects ?? [])
            } catch {
                self.publisher.send(completion: .failure(error))
            }
        }
    }
    
    @objc func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        publisher.send(fetchedResultsController.fetchedObjects ?? [])
    }
}
