import SwiftUI

struct IntroView: View {
   
    @EnvironmentObject var selection: Selection
    
    var body: some View {
        VStack {
            Text("Hey there! I'm Annie. I started skydiving on my 18th birthday and was instantly hooked. I've noticed a lot of people have the wrong idea about skydiving—they think it's all about falling and danger. But it's so much more. It's about control, physics, and pure joy. lets Experience the thrill of skydiving and the fun of physics in one adventure! Ready to dive into the sky?")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            Button("Let's go!"){
                selection.value = 1
            }
                .foregroundColor(.black)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
}
