import SwiftUI
import Knob

/**
 Wrapper for a Knob control that allows it to reside in and take part in a SwiftUI view definition.
 */
struct KnobView: UIViewRepresentable {

  /// The current value of the Knob
  @Binding var value: Float
  /// Signal that the knob is being manipulated
  @Binding var manipulating: Bool

  /**
   Create a new Knob control to be managed in SwiftUI.

   - parameter context: the context where the control will live
   - returns: the new Knob control
   */
  func makeUIView(context: Context) -> Knob {
    let knob = Knob()
    knob.trackLineWidth = 12.0
    knob.trackColor = .darkGray

    knob.progressLineWidth = 10.0
    knob.progressColor = .systemOrange

    knob.indicatorLineLength = 0.0

    // Use the coordinator to monitor value changes in the Knob and forward them to the binding
    context.coordinator.monitor(knob)

    return knob
  }

  /**
   Update the Knob to show changes in the value binding.

   - parameter uiView: the Knob to update
   - parameter context: the context where the control lives
   */
  func updateUIView(_ view: Knob, context: Context) { view.value = value }

  /**
   Create a new coordinator that will monitor the Knob value changes.

   - returns: new Coordinator
   */
  func makeCoordinator() -> KnobView.Coordinator { Coordinator(self) }

  /**
   Coordinator allows us to monitor valueChanged actions from a Knob and forward the values to the binding in the
   KnobView
   */
  class Coordinator: NSObject {
    private var knobView: KnobView

    init(_ knobView: KnobView) { self.knobView = knobView }
    func monitor(_ knob: Knob) { knob.addTarget(self, action: #selector(valueChanged), for: .valueChanged) }
    @objc func valueChanged(_ sender: Knob) {
      knobView.value = sender.value
      knobView.manipulating = sender.manipulating
    }
  }
}

