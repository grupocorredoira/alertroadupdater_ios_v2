import SwiftUI

struct NumericCodeTextFieldView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var borderColor: UIColor

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.keyboardType = .numberPad
        textField.delegate = context.coordinator

        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderColor.cgColor
        textField.borderStyle = .none
        textField.setLeftPaddingPoints(12)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.layer.borderColor = borderColor.cgColor
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
                return false
            }
            
            let current = textField.text ?? ""
            guard let stringRange = Range(range, in: current) else { return false }
            let updatedText = current.replacingCharacters(in: stringRange, with: string)

            if updatedText.count <= 6 {
                text = updatedText
                return true
            } else {
                return false
            }
        }
    }
}

private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        leftView = padding
        leftViewMode = .always
    }
}
