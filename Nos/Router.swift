//
//  Router.swift
//  Nos
//
//  Created by Jason Cheatham on 2/21/23.
//

import SwiftUI
import CoreData

// Manages the app's navigation state.
class Router: ObservableObject {
    
    @Published var homeFeedPath = NavigationPath()
    @Published var discoverPath = NavigationPath()
    @Published var notificationsPath = NavigationPath()
    @Published var relayPath = NavigationPath()
    @Published var sideMenuPath = NavigationPath()
    @Published var selectedTab = AppView.Destination.home
    
    var currentPath: Binding<NavigationPath> {
        if sideMenuOpened {
            return Binding(get: { self.sideMenuPath }, set: { self.sideMenuPath = $0 })
        }
        
        switch selectedTab {
        case .home:
            return Binding(get: { self.homeFeedPath }, set: { self.homeFeedPath = $0 })
        case .discover:
            return Binding(get: { self.discoverPath }, set: { self.discoverPath = $0 })
        case .newNote:
            return Binding(get: { self.homeFeedPath }, set: { self.homeFeedPath = $0 })
        case .notifications:
            return Binding(get: { self.notificationsPath }, set: { self.notificationsPath = $0 })
        case .relays:
            return Binding(get: { self.relayPath }, set: { self.relayPath = $0 })
        }
    }
    
    @Published var userNpubPublicKey = ""
    
    @Published private(set) var sideMenuOpened = false
    
    func toggleSideMenu() {
        withAnimation(.easeIn(duration: 0.2)) {
            sideMenuOpened.toggle()
        }
    }
    
    func closeSideMenu() {
        withAnimation(.easeIn(duration: 0.2)) {
            sideMenuOpened = false
        }
    }
    
    /// Pushes the given destination item onto the current NavigationPath.
    func push<D: Hashable>(_ destination: D) {
        currentPath.wrappedValue.append(destination)
    }
}

extension Router {
    
    func open(url: URL, with context: NSManagedObjectContext) {
        let link = url.absoluteString
        // handle mentions. mention link will be prefixed with "@" followed by
        // the hex format pubkey of the mentioned author
        if link.hasPrefix("@") {
            let authorPubkey = String(link[link.index(after: link.startIndex)...])
            if let author = try? Author.find(by: authorPubkey, context: context) {
                currentPath.wrappedValue.append(author)
            }
        }
    }
}
