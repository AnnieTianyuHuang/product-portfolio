//
//  Connect.swift
//  Forge UX Demo
//
//  Created by Race Li on 2023/8/7.
//

import SwiftUI
//import Solana

struct ConnectView: View {
    @State private var isConnecting: Bool = false
//    private let solanaClient = SolanaClient(endpoint: .mainnetBeta)
    
    var body: some View {
        VStack {
            HStack {
                Text("Connect or Login")
                    .font(.system(size: 32, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 21)
            .padding(.top, 21)
            
            Text("""
Creating content on the Forge platform requires either a wallet connect or email login. This requirement ensures that your contributions are recorded on the blockchain, allowing real-time feedback and the accumulation of points for creators at their respective addresses.

If you choose to log in with an email, we will automatically create a wallet address for you. This way, your earned points are securely stored and readily available for extraction. When the need arises to withdraw your points, you can then complete the wallet creation process.

By requiring a wallet connect or email login, we ensure transparency, security, and convenience in managing your creative contributions and rewards on Forge.
""")
            .padding(.horizontal, 21)
            .padding(.top, 8)
            
            
            Spacer()
            
            Button(action: {
                self.isConnecting = true
//                do {
//                    let account = try Account(phrase: "replace with your mnemonic phrase here", network: .mainnetBeta)
//                    self.getAccountBalance(account: account)
//                } catch {
//                    print("Failed to create account: \(error)")
//                    self.isConnecting = false
//                }
            }) {
                Text("Connect Wallet")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 24)
                    .padding()
                    .foregroundColor(Color("controlWithBackground"))
                    .background(Color("control"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 21)
                    .padding(.bottom, 8)
                    .disabled(self.isConnecting)
            }
            .disabled(self.isConnecting)
            
            Button(action: {
                // action for Join Curator button
            }) {
                Text("Login with email")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 24)
                    .padding()
                    .foregroundColor(Color("controlWithBackground"))
                    .background(Color("control"))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 21)
                    .padding(.bottom, 24)
            }
        }
    }
    
//    private func getAccountBalance(account: Account) {
//        solanaClient.api.getBalance(account: account.publicKey.base58EncodedString) { result in
//            switch result {
//            case .success(let lamports):
//                print("Account balance: \(lamports)")
//            case .failure(let error):
//                print("Failed to fetch account balance: \(error.localizedDescription)")
//            }
//            self.isConnecting = false
//        }
//    }
}

struct Connect_Previews: PreviewProvider {
    static var previews: some View {
        ConnectView()
    }
}
