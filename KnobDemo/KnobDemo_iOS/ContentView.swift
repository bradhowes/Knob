// Copyright © 2021 Brad Howes. All rights reserved.

import SwiftUI
import Knob_iOS

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
    let trackWidth: CGFloat = 14
    let trackColor = Color(red: 0.25, green: 0.25, blue: 0.25)
    let progressWidth: CGFloat = 12
    let progressColor = Color(red: 1.0, green: 0.575, blue: 0.0)

    ZStack {
      Color.black
        .ignoresSafeArea()
      VStack(
        alignment: .center,
        spacing: 10
      ) {
        Text("Touch/click inside arc and move up/down")
          .accessibilityIdentifier("title")
          .font(.system(size: 14, weight: .medium, design: .default))
          .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))

        HStack(alignment: .center, spacing: 10) {
          VStack(alignment: .center, spacing: 10) {
            KnobView(value: $volumeValue, manipulating: $volumeManipulating)
              .trackStyle(width: trackWidth, color: trackColor)
              .progressStyle(width: progressWidth, color: progressColor)
              .indicatorStyle(width: progressWidth, color: progressColor, length: 0.3)
              .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
              .accessibilityIdentifier("volume knob")

            let textValue = volumeManipulating ? valueFormatter.string(for: volumeValue * 100.0) ?? "?" : "Volume"
            let duration = volumeManipulating ? 0.0 : 0.4
            let delay = volumeManipulating ? 0.0 : 0.5
            Text(textValue)
              .padding(Edge.Set(.top), -24)
              .font(.system(size: 24, weight: .medium, design: .default))
              .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))
              .accessibilityIdentifier("volume label")
              .transition(.opacity.animation(.linear(duration: duration).delay(delay)))
              .id("Volume \(volumeManipulating)")
          }
          VStack(alignment: .center, spacing: 10) {
            KnobView(value: $delayValue, manipulating: $delayManipulating)
              .trackStyle(width: trackWidth, color: trackColor)
              .progressStyle(width: progressWidth, color: progressColor)
              .indicatorStyle(width: progressWidth, color: progressColor, length: 0.3)
              .frame(minWidth: 40, maxWidth: 240, minHeight: 40, maxHeight: 240)
              .accessibilityIdentifier("delay knob")

            let textValue = delayManipulating ? valueFormatter.string(for: delayValue * 100.0) ?? "?" : "Delay"
            let duration = delayManipulating ? 0.0 : 0.4
            let delay = delayManipulating ? 0.0 : 0.5
            Text(textValue)
              .padding(Edge.Set(.top), -24)
              .font(.system(size: 24, weight: .medium, design: .default))
              .foregroundColor(Color(red: 0.7, green: 0.5, blue: 0.3))
              .accessibilityIdentifier("delay label")
              .transition(.opacity.animation(.linear(duration: duration).delay(delay)))
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
