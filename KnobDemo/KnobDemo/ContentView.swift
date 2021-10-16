import SwiftUI

struct ContentView: View {
  @State var value: Float = 0.25

  var body: some View {
    VStack(
      alignment: .center,
      spacing: 10
    ) {
      KnobView(value: $value)
        .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
        .accessibilityHint("Adjust value")
        .accessibilityLabel("knob")
      Text("\(value)")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
    }
  }
}
