import UIKit

final class KeyboardWarmup {
	static func prewarm(on window: UIWindow? = UIApplication.shared.connectedScenes
		.compactMap { $0 as? UIWindowScene }
		.flatMap { $0.windows }
		.first(where: { $0.isKeyWindow })) {
		guard let window else { return }
		let textField = UITextField(frame: .zero)
		textField.isHidden = true
		textField.accessibilityElementsHidden = true
		textField.isAccessibilityElement = false
		window.addSubview(textField)
		textField.becomeFirstResponder()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			textField.resignFirstResponder()
			textField.removeFromSuperview()
            textField.isUserInteractionEnabled = false
		}
	}
}


