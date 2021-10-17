import SwiftUI
import AppKit

struct ContentView: View {
  @State var value: Float = 0.25

  var body: some View {
    VStack(
      alignment: .center,
      spacing: 10
    ) {
      Text("Touch/click inside arc and move up/down")
        .accessibilityIdentifier("title")
      KnobView(value: $value)
        .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
        .accessibilityIdentifier("knob")
      Text("\(value)")
        .accessibilityIdentifier("value")
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
