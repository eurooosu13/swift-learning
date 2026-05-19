import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var normalizedToken: String {
        trimmed
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")
            .replacingOccurrences(of: " ", with: "-")
    }
    
    // Day1: String Blank Detection
    var isBlank: Bool {
        trimmed
            .isEmpty
    }
}
