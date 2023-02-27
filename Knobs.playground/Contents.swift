//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import Knob-iOS

class MyViewController : UIViewController {
  
  let knobLabel = "Volume"
  
  let knob = Knob()
  let label = UILabel()
  lazy var stackView = UIStackView(arrangedSubviews: [knob, label])
  let valueFormatter = NumberFormatter()
  
  var restorationTimer: Timer?
  
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .black
    self.view = view
    
    stackView.axis = .vertical
    // stackView.spacing = -10
    
    view.addSubview(stackView)

    // knob.valueLabel = label
    // knob.valueName = knobLabel

//    knob.trackWidthFactor = 0.1
//    knob.trackColor = .darkGray.withAlphaComponent(0.2)
//
//    knob.progressWidthFactor = 0.8
//    knob.progressColor = .systemBlue
//
//    knob.indicatorWidthFactor = 0.4
//    knob.indicatorColor = .systemBlue
//
//    knob.tickCount = 5
//    knob.tickColor = .systemBlue.withAlphaComponent(0.3)
//    knob.tickLineOffset = 0.15
//    knob.tickLineLength = 0.22
//
//    knob.touchSensitivity = 2.0
//
    knob.maximumValue = 100.0
    knob.minimumValue = 0.0
    knob.setValue(30.0)

    // knob.addTarget(self, action: #selector(updateLabel), for: .valueChanged)
    // knob.addTarget(self, action: #selector(restoreLabel), for: .touchCancel)
    
//    valueFormatter.minimumFractionDigits = 2
//    valueFormatter.maximumFractionDigits = 2
//    valueFormatter.maximumIntegerDigits = 3
//    knob.valueFormatter = valueFormatter

//    label.textAlignment = .center
//    label.textColor = .systemBlue
//    label.text = knobLabel
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let size: CGFloat = 180.0
    stackView.frame = CGRect(x: view.bounds.midX - size / 2, y: view.bounds.midY - size / 2, width: size, height: size)
  }
  
//  @IBAction func updateLabel(_ sender: Any) {
//    label.layer.removeAllAnimations()
//    label.text = valueFormatter.string(from: NSNumber(value: knob.value))
//  }
//  
//  @IBAction func restoreLabel(_ sender: Any) {
//    self.restorationTimer?.invalidate()
//    self.restorationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
//      guard let self = self else { return }
//      UIView.transition(with: self.label, duration: 0.5, options: [.curveLinear, .transitionCrossDissolve]) {
//        self.label.text = self.knobLabel
//      } completion: { _ in
//        self.label.text = self.knobLabel
//      }
//    }
//  }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
