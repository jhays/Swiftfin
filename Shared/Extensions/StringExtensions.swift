import Foundation

extension String {
    func removeRegexMatches(pattern: String, replaceWith: String = "") -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: count)
            return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replaceWith)
        } catch { return self }
    }

    func leftPad(toWidth width: Int, withString string: String?) -> String {
        let paddingString = string ?? " "

        if self.count >= width {
            return self
        }

        let remainingLength: Int = width - self.count
        var padString = String()
        for _ in 0 ..< remainingLength {
            padString += paddingString
        }

        return "\(padString)\(self)"
    }
}
