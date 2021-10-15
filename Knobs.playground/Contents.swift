//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import Knob

class MyViewController : UIViewController {

    let knob = Knob()
    let label = UILabel()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view
        view.addSubview(knob)
        view.addSubview(label)

        knob.trackLineWidth = 10.0
        knob.progressLineWidth = 6.0
        knob.indicatorLineWidth = 6.0
        knob.setValue(0.3)
        knob.touchSensitivity = 2.0
        knob.tickCount = 5
        knob.tickColor = .blue
        knob.tickLineLength = 0.2

        knob.addTarget(self, action: #selector(update), for: .valueChanged)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size: CGFloat = 120.0

        knob.frame = CGRect(x: view.bounds.midX - size / 2, y: view.bounds.midY - size / 2, width: size, height: size)
        view.addSubview(knob)

        label.frame = CGRect(x: view.bounds.midX - 60, y: view.bounds.midY + size / 2 + 20, width: 120, height: 40)
        label.text = "\(knob.value)"

    }

    @IBAction func update(_ sender: Any) {
        label.text = "\(knob.value)"
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
