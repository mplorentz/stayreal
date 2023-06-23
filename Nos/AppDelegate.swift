import Foundation
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {

    private var relayService: RelayService // todo how to get this?
    private var notificationRegistrationEventType: Int64 = 6666
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        do {
            try self.sendDeviceTokenToServer(deviceToken: deviceToken)
        }
        catch {
            print("error sending apns token to server: \(error)")
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("apns error", error)
    }
    
    private func sendDeviceTokenToServer(deviceToken: Data) throws {
        let publicKeyHex = CurrentUser.shared.publicKeyHex;
        
        let relays = [RegistrationRelayAddress(address: "test")]
        let content = Registration(
            apnsToken: deviceToken.hexString,
            publicKey: publicKeyHex!,
            relays: relays
        )
        let encodedContent = String(data: try JSONEncoder().encode(content), encoding: .utf8)
        let jsonEvent = JSONEvent(
            id: "", // ???? why not a different type
            pubKey: CurrentUser.shared.keyPair?.publicKeyHex!,
            createdAt: Int64(Date().timeIntervalSince1970),
            kind: notificationRegistrationEventType,
            tags: [],
            content: encodedContent,
            signature: ""
        )
        
        print("apns sending", jsonEvent)
        
        let selectedRelay = Relay()
        
        try await self.relayService.publish(
            event: jsonEvent,
            to: selectedRelay,
            signingKey: CurrentUser.shared.keyPair!,
            context: nil // todo how to not pass this?
        )
        
        // todo how to get our relays?
        // todo how to connect to a relay and send an event to it?
    }
}

struct Registration: Codable {
    var apnsToken: String
    var publicKey: String
    var relays: [RegistrationRelayAddress]
    
    enum CodingKeys: String, CodingKey {
        case apnsToken = "apnsToken"
        case publicKey = "publicKey"
        case relays = "relays"
    }
}

struct RegistrationRelayAddress: Codable {
    var address: String
    
    enum CodingKeys: String, CodingKey {
        case address = "address"
    }
}
