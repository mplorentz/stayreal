//
//  HomeFeedView.swift
//  Nos
//
//  Created by Matthew Lorentz on 1/31/23.
//

import SwiftUI
import CoreData

struct HomeFeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var relayService: RelayService

    @FetchRequest(fetchRequest: Event.allPostsRequest(), animation: .default)
    private var events: FetchedResults<Event>
    
    @State var isCreatingNewPost = false
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(events) { event in
                    VStack {
                        NoteButton(note: event)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .background(Color.appBg)
        .sheet(isPresented: $isCreatingNewPost, content: {
            NewPostView(isPresented: $isCreatingNewPost)
        })
        .overlay(Group {
            if events.isEmpty {
                Localized.noEvents.view
            }
        })
        .toolbar {
            ToolbarItem {
                Button {
                    isCreatingNewPost.toggle()
                }
                label: {
                    Label(Localized.noEvents.string, systemImage: "plus")
                }
            }
        }
        .navigationTitle(Localized.homeFeed.string)
        .task {
            load()
        }
        .refreshable {
            load()
        }
    }
    
    private func load() {
        relayService.requestEventsFromAll()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    
    static var persistenceController = PersistenceController.preview
    static var previewContext = persistenceController.container.viewContext
    static var relayService = RelayService(persistenceController: persistenceController)
    
    static var emptyPersistenceController = PersistenceController.empty
    static var emptyPreviewContext = emptyPersistenceController.container.viewContext
    static var emptyRelayService = RelayService(persistenceController: emptyPersistenceController)
    
    static var shortNote: Event {
        let note = Event(context: previewContext)
        note.content = "Hello, world!"
        return note
    }
    
    static var longNote: Event {
        let note = Event(context: previewContext)
        note.content = .loremIpsum(5)
        return note
    }
    
    static var previews: some View {
        NavigationView {
            HomeFeedView()
        }
        .environment(\.managedObjectContext, previewContext)
        .environmentObject(relayService)
        
        NavigationView {
            HomeFeedView()
        }
        .environment(\.managedObjectContext, emptyPreviewContext)
        .environmentObject(emptyRelayService)
    }
}
