import SwiftUI
import AppKit

struct ContentView: View {
  @State var value: Float = 0.25
  @State var manipulating: Bool = false

  let valueFormatter: NumberFormatter = {
    let valueFormatter = NumberFormatter()
    valueFormatter.maximumFractionDigits = 2
    valueFormatter.minimumFractionDigits = 2
    valueFormatter.maximumIntegerDigits = 3
    valueFormatter.minimumIntegerDigits = 1
    return valueFormatter
  }()

  var body: some View {
    VStack(
      alignment: .center,
      spacing: 0
    ) {
      Text("Touch/click inside arc and move up/down")
        .accessibilityIdentifier("title")
        .font(.system(size: 14, weight: .medium, design: .default))
        .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))

      KnobView(value: $value, manipulating: $manipulating)
        .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
        .accessibilityIdentifier("knob")

      let textValue = manipulating ? valueFormatter.string(for: value * 100.0) ?? "?" : "Volume"
      let duration = manipulating ? 0.0 : 0.4
      let delay = manipulating ? 0.0 : 0.5
      Text(textValue)
        .padding(Edge.Set(.top), -24)
        .font(.system(size: 24, weight: .medium, design: .default))
        .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))
        .accessibilityIdentifier("value")
        .transition(.opacity.animation(.linear(duration: duration).delay(delay)))
        .id("Volume \(manipulating)")
    }
    .padding(12)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
    }
  }
}
