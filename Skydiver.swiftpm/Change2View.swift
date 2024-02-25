import SwiftUI

struct Change2View: View {
    @EnvironmentObject var selection: Selection
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Try Lower")
                    .font(.title)
                    .foregroundColor(.white)
                Text("Oh, you soared above the Kármán Line (100km)! Drift into the void of space, where Earth's grasp weakens. Now try Experience the thrill of skydiving from lower altitudes. Can you make a perfect landing?")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Button("Replay Prev") {
                    selection.value = 2
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                
                Button("Try Lower") {  // 新增的按钮
                    selection.value = 3
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)  // 为了区分，使用不同的颜色
                .cornerRadius(10)
            }
            .padding()
        }
    }
}
