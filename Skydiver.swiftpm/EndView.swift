import SwiftUI

struct EndView: View {
    @EnvironmentObject var selection: Selection
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20){
                Text("Each cloud passed increases drag, making it harder to control the descent. Overwhelmed by the fluff, the parachute fails to deploy in time. NOW KEEP TRYING, AND ENJOY!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                Button("Replay") {
                    selection.value = 4
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
    }
}
            

