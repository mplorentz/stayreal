//
//  SideMenuContent.swift
//  Nos
//
//  Created by Jason Cheatham on 2/21/23.
//
import SwiftUI
struct SideMenuContent: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var router: Router
    let closeMenu: () -> Void
    var body: some View {
        NavigationStack(path: $router.sideMenuPath) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                HStack {
                    Button {
                        do {
                            guard let keyPair = KeyPair.loadFromKeychain() else { return }
                            let author = try Author.findOrCreate(by: keyPair.publicKeyHex, context: viewContext)
                            router.sideMenuPath.append(author)
                        } catch {
                            // Replace this implementation with code to handle the error appropriately.
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "person.crop.circle")
                            Text("Your Profile")
                                .foregroundColor(.primaryTxt)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                HStack {
                    Button {
                        router.sideMenuPath.append(SideMenu.Destination.settings)
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "gear")
                            Text("Settings")
                                .foregroundColor(.primaryTxt)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                HStack {
                    Button {
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "questionmark.circle")
                            Text("Help and Support")
                                .foregroundColor(.primaryTxt)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                HStack {
                    Button {
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "ant.circle.fill")
                            Text("Report a Bug")
                                .foregroundColor(.primaryTxt)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                Spacer(minLength: 0)
            }
            .background(Color.appBg)
            .navigationDestination(for: Author.self) { author in
                ProfileView(author: author)
            }
            .navigationDestination(for: SideMenu.Destination.self) { _ in
                SettingsView()
            }
        }
    }
}
