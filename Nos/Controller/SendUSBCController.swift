//
//  SendUSBCController.swift
//  Nos
//
//  Created by Matthew Lorentz on 10/23/23.
//

import Foundation
import Dependencies
import Combine
import WalletConnectUtils
import WalletConnectPairing
import WalletConnectRelay
import WalletConnectSign
import Auth
import Logger
import SwiftUI

typealias USBCAddress = String

enum SendUSBCWizardState {
    case pair, amount, error(Error), loading
}

enum SendUSBCError: Error {
    case missingFromAddress
    case developer
    case noSession
    case couldNotCreateTransaction
}

/// A controller to support pairing with a wallet using Wallet Connect 2.0 and sending USBC to another Nostr user with
/// a universal name.
class SendUSBCController: ObservableObject {
    @Dependency(\.currentUser) private var currentUser
    
    @Published var state: SendUSBCWizardState
    @Published var fromAddress: USBCAddress?
    @Published var qrImage: Image?
    @Published var qrCodeValue: String?
    var destinationAddress: USBCAddress
    var destinationAuthor: Author
    
    private var cancellables = [AnyCancellable]()
    private let walletConnectManager = WalletConnectManager.shared
    private var dismissHandler: () -> Void
    
    init(
        state: SendUSBCWizardState = .loading, 
        destinationAddress: USBCAddress, 
        destinationAuthor: Author,
        dismiss: @escaping () -> Void
    ) {
        self.state = state
        self.destinationAddress = destinationAddress
        self.destinationAuthor = destinationAuthor
        self.dismissHandler = dismiss
        
        Task { try? await initiateConnectionToWC() }
        
        walletConnectManager.onReinitiateConnection = {
            Task {
                try? await self.initiateConnectionToWC()
            }
        }
        
        walletConnectManager.onSessionInitiated = { [weak self] _ in 
            Task { @MainActor [weak self] in
                self?.updateStep()
            }
        }
        
        walletConnectManager.onSessionResponse = { [weak self] response in
            switch response.result {
            case .response:
                self?.dismissHandler()
            case .error(let error):
                self?.state = .error(error)
            }
        }
        
        Task {
            do {
                _ = try await walletConnectManager.initiateConnectionRequest()
            } catch {
                self.state = .error(error)
            }
            await updateStep()
        }
        
        currentUser.$usbcAddress.sink { [weak self] newAddress in
            self?.fromAddress = newAddress
        }
        .store(in: &cancellables)
    }
    
    @MainActor func updateStep() {
        if let session = walletConnectManager.getAllSessions().last {
            walletConnectManager.saveInitiatedSessions(sessions: session)
            state = .amount
        } else {
            state = .pair
        }
    }
    
    @MainActor func startOver() {
        updateStep()
    }
    
    func initiateConnectionToWC() async throws {
        let wcDeeplink = try await walletConnectManager.initiateConnectionRequest()
        let globalIDDeeplink = "\(globalIDURLScheme)wc?uri=\(wcDeeplink)"
        await MainActor.run {
            Logger.Log.info("Generated WalletConnect URI: \(globalIDDeeplink)")
            qrCodeValue = globalIDDeeplink
            qrImage = globalIDDeeplink.generateQRCode()
        }
    }
    
    func copyLinkPressed() {
        UIPasteboard.general.string = qrCodeValue
    }
    
    func connectPressed() {
        guard let qrCodeValue, let url = URL(string: qrCodeValue) else {
            Log.error("Could not construct URL")
            return
        }
        
        UIApplication.shared.open(url) { success in
            if !success {
                UIApplication.shared.open(
                    URL(string: "https://apps.apple.com/us/app/globalid-private-digital-id/id1439340119")!
                )
            }
        }
    }
    
    @MainActor func sendPayment(_ amount: String) async throws {
        guard let fromAddress else {
            state = .error(SendUSBCError.missingFromAddress)
            return
        }
        
        state = .loading
        
        try await walletConnectManager.sendTransaction(
            fromAddress: fromAddress, 
            toAddress: destinationAddress, 
            amount: amount, 
            blockChain: .universalLedger
        )
        
        guard let url = URL(string: globalIDURLScheme) else {
            throw SendUSBCError.developer
        }
        
        await UIApplication.shared.open(url) 
    }
}
