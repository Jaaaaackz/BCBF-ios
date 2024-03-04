//
//  CoreDataController.swift
//  BCBF
//
//  Created by user216835 on 5/6/22.
//


import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    
    var allNightLocationFetchedResultsController: NSFetchedResultsController<NightLocation>?
    
    let DEFAULT_USER_NAME = "Default User"
    let DEFAULT_USER_NICKNAME="Test"
    let DEFAULT_USER_WHATSUP="This is a Test"
    
    var userNightLocationFetchedResultsController: NSFetchedResultsController<NightLocation>?
    
    // MARK: - Lazy Initilisation of Default Team
    lazy var defaultUser: User = {
        var user = [User]()
        let request: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "name = %@", DEFAULT_USER_NAME)
        request.predicate = predicate
        
        do {
            try user = persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch Request Failed: \(error)")
        }
        if let User = user.first {
            return User
        }
        return addUser(userName: DEFAULT_USER_NAME, nickName: DEFAULT_USER_NICKNAME, whatsUp: DEFAULT_USER_WHATSUP)
    }()

    
    override init() {
        persistentContainer = NSPersistentContainer(name: "BCBF-DataModel")
        persistentContainer.loadPersistentStores() {
            (description, error ) in
            if let error = error {
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
        createDefaultNightLocation()
    }
    
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .nightLocation || listener.listenerType == .all {
            listener.onNightLocationChange(change: .update, userNightLocation: fetchAllNightLocation())
        }
        
        if listener.listenerType == .user || listener.listenerType == .all {
            listener.onUserChange(change: .update, userNightLocation: fetchUserNightLocation())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func addNightLocation(times: Int32, latitude: Double, longitude: Double) -> NightLocation {
        let location = NSEntityDescription.insertNewObject(forEntityName: "NightLocation", into: persistentContainer.viewContext) as! NightLocation
        location.times=times
        location.latitude=latitude
        location.longitude=longitude
        return location
    }
    
    func deleteNightLocation(nightLocation: NightLocation) {
        persistentContainer.viewContext.delete(nightLocation)
    }
    
    func fetchAllNightLocation() -> [NightLocation] {
        print("Start fetch night location")
        if allNightLocationFetchedResultsController == nil {
            let request: NSFetchRequest<NightLocation> = NightLocation.fetchRequest()
            let timeSortDescriptor = NSSortDescriptor(key: "times", ascending: true)
            request.sortDescriptors = [timeSortDescriptor]
            // Initialise Fetched Results Controller
            allNightLocationFetchedResultsController = NSFetchedResultsController<NightLocation>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext,sectionNameKeyPath: nil,cacheName: nil)
            // Set this class to be the results delegate
            allNightLocationFetchedResultsController?.delegate = self
            do {
                try allNightLocationFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        if let records = allNightLocationFetchedResultsController?.fetchedObjects {
            return records
        }
        
        return [NightLocation]()
        
        

    }
    
    
    func addUser(userName: String, nickName: String, whatsUp: String) -> User {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: persistentContainer.viewContext) as! User
        user.username=userName
        user.nickname=nickName
        user.whatsUp=whatsUp
        return user
    }
    
    func deleteUser(user: User) {
        persistentContainer.viewContext.delete(user)
    }
    
    func addNightLocationToUser(nightLocation: NightLocation, user: User) {
        nightLocation.addToUser(user)
    }
    
    func removeNightLocationFromUser(nightLocation: NightLocation, user: User) {
        nightLocation.removeFromUser(user)
    }
    
    func createDefaultNightLocation() {
        let _ = addNightLocation(times:Int32(5), latitude: -37.9095864, longitude: 145.1319627)
        let _ = addNightLocation(times:Int32(3), latitude: -37.9195864, longitude: 145.1319627)
        let _ = addNightLocation(times:Int32(2), latitude: -37.9295864, longitude: 145.1319627)
        let _ = addNightLocation(times:Int32(1), latitude: -37.9395864, longitude: 145.1319627)
        let _ = addNightLocation(times:Int32(7), latitude: -37.9495864, longitude: 145.1319627)

        cleanup()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allNightLocationFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .nightLocation
                    || listener.listenerType == .all {
                    listener.onNightLocationChange(change: .update, userNightLocation: fetchAllNightLocation())
                }
            }
        } else if controller == userNightLocationFetchedResultsController {
            listeners.invoke { (listener) in
            if listener.listenerType == .user || listener.listenerType == .all {
                listener.onUserChange(change: .update, userNightLocation: fetchUserNightLocation())
            } }
            }
    }
    
    func fetchUserNightLocation() -> [NightLocation] {
        if userNightLocationFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<NightLocation> = NightLocation.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "username", ascending: true)
            let predicate = NSPredicate(format: "ANY user.username == %@", DEFAULT_USER_NAME)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            fetchRequest.predicate = predicate
            
            userNightLocationFetchedResultsController = NSFetchedResultsController<NightLocation>(fetchRequest: fetchRequest,
                                                                                       managedObjectContext: persistentContainer.viewContext,
                                                                                       sectionNameKeyPath: nil, cacheName: nil)
            userNightLocationFetchedResultsController?.delegate = self
            do {
                try userNightLocationFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        var nightRecord = [NightLocation]()
        if userNightLocationFetchedResultsController?.fetchedObjects != nil {
            nightRecord = (userNightLocationFetchedResultsController?.fetchedObjects)!
        }
        
        return nightRecord
    }
}
