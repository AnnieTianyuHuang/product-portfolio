import SwiftUI

struct Change1View: View {
    @EnvironmentObject var selection: Selection
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Now that we've tackled typical heights, why not aim higher? Experience the thrill of skydiving at 100km, where the sky meets space.")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                
                Button("Replay Prev") {
                    selection.value = 1
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.gray)
                .cornerRadius(10)
                
                Button("Try Higher") {
                    selection.value = 2
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue) // Different background color for distinction
                .cornerRadius(10)
            }
        }
    }
}
