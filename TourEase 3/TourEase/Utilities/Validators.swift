import Foundation

enum Validators {
    static func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }

    /// Min 8 chars, at least one letter and one number.
    static func isValidPassword(_ password: String) -> Bool {
        password.count >= 8 &&
        password.contains(where: { $0.isLetter }) &&
        password.contains(where: { $0.isNumber })
    }

    static func passwordStrengthLabel(_ password: String) -> String {
        switch password.count {
        case 0: return ""
        case 1..<8: return "Weak"
        case 8..<12: return isValidPassword(password) ? "Good" : "Weak"
        default: return isValidPassword(password) ? "Strong" : "Good"
        }
    }
}
