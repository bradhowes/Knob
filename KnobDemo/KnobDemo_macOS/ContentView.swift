// Copyright © 2021 Brad Howes. All rights reserved.

import SwiftUI
import Knob_macOS

struct ContentView: View {
  @State var volumeValue: Float = 0.25
  @State var volumeManipulating: Bool = false

  @State var delayValue: Float = 0.25
  @State var delayManipulating: Bool = false

  let valueFormatter: NumberFormatter = {
    let valueFormatter = NumberFormatter()
    valueFormatter.maximumFractionDigits = 2
    valueFormatter.minimumFractionDigits = 2
    valueFormatter.maximumIntegerDigits = 3
    valueFormatter.minimumIntegerDigits = 1
    return valueFormatter
  }()

  var body: some View {
    let trackWidthFactor: CGFloat = 0.08
    let trackColor = Color(red: 0.25, green: 0.25, blue: 0.25)
    let progressWidthFactor: CGFloat = 0.055
    let progressColor = Color(red: 1.0, green: 0.575, blue: 0.0)
    let textColor = Color(red: 0.7, green: 0.5, blue: 0.3)

    ZStack {
      Color.black
        .ignoresSafeArea()

      VStack(alignment: .center, spacing: 10) {

        Text("Touch/click inside arc and move up/down")
          .accessibilityIdentifier("title")
          .font(.system(size: 14, weight: .medium, design: .default))
          .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))

        HStack(alignment: .center, spacing: 10) {

          VStack(alignment: .center, spacing: -24) {

            KnobView(value: $volumeValue, manipulating: $volumeManipulating)
              .trackStyle(widthFactor: trackWidthFactor, color: trackColor)
              .progressStyle(widthFactor: progressWidthFactor, color: progressColor)
              .indicatorStyle(widthFactor: progressWidthFactor, color: progressColor, length: 0.3)
              .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
              .accessibilityIdentifier("volume knob")
              .aspectRatio(1.0, contentMode: .fit)

            let textValue = volumeManipulating ? valueFormatter.string(for: volumeValue * 100.0) ?? "?" : "Volume"
            let inDuration = volumeManipulating ? 0.0 : 0.4
            let inDelay = volumeManipulating ? 0.0 : 0.5
            let outDuration = volumeManipulating ? 0.4 : 0.0
            let outDelay = volumeManipulating ? 0.5 : 0.0

            Text(textValue)
              .font(.system(size: 24, weight: .medium, design: .default))
              .foregroundColor(textColor)
              .accessibilityIdentifier("volume label")
              .transition(.asymmetric(
                insertion: .opacity.animation(.linear(duration: inDuration).delay(inDelay)),
                removal: .opacity.animation(.linear(duration: outDuration).delay(outDelay))))
              .id("Volume \(volumeManipulating)")
          }

          VStack(alignment: .center, spacing: -24) {

            KnobView(value: $delayValue, manipulating: $delayManipulating)
              .trackStyle(widthFactor: trackWidthFactor, color: trackColor)
              .progressStyle(widthFactor: progressWidthFactor, color: progressColor)
              .indicatorStyle(widthFactor: progressWidthFactor, color: progressColor, length: 0.3)
              .accessibilityIdentifier("delay knob")
              .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
              .aspectRatio(1.0, contentMode: .fit)

            let textValue = delayManipulating ? valueFormatter.string(for: delayValue * 100.0) ?? "?" : "Delay"
            let inDuration = volumeManipulating ? 0.0 : 0.4
            let inDelay = volumeManipulating ? 0.0 : 0.5
            let outDuration = volumeManipulating ? 0.4 : 0.0
            let outDelay = volumeManipulating ? 0.5 : 0.0

            Text(textValue)
              .font(.system(size: 24, weight: .medium, design: .default))
              .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))
              .accessibilityIdentifier("delay label")
              .transition(.asymmetric(
                insertion: .opacity.animation(.linear(duration: inDuration).delay(inDelay)),
                removal: .opacity.animation(.linear(duration: outDuration).delay(outDelay))))
              .id("Delay \(delayManipulating)")
          }
        }
      }
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
