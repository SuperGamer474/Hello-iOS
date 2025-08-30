import SwiftUI
struct ContentView: View {
    var body: some View {
        VStack(spacing:20) {
            Text("Unsigned IPA built by GitHub Actions 🚀")
                .font(.title2)
                .padding()
            Text("Re-sign me later 😉")
                .font(.subheadline)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
