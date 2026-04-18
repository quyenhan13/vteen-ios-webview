import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "TEST MOI 123"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
