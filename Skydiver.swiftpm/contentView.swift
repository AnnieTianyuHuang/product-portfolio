import SwiftUI

struct ContentView: View {
    @EnvironmentObject var selection: Selection

    var body: some View {
        ZStack {
            Group{
                switch selection.value {
                case 0:
                    IntroView().environmentObject(selection)
                case 1, 5:
                    PhaseOneView().environmentObject(selection)
                case 2, 6:
                    PhaseTwoView().environmentObject(selection)
                case 3, 7:
                    PhaseThreeView().environmentObject(selection)
                case 4, 8:
                    PhaseFourView().environmentObject(selection)
                default:
                    Text("Main content for selection \(selection.value)")
                }
            }.zIndex(1)

            // Overlay views
            if selection.value == 5 {
                Change1View().environmentObject(selection)
//                    .zIndex(2)
            }
            if selection.value == 6 {
                Change2View().environmentObject(selection)
            }
            if selection.value == 7 {
                Change3View().environmentObject(selection)
            }
            if selection.value == 8 {
                EndView().environmentObject(selection)
            }
        }
    }
}
