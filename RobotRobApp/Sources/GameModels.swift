import Foundation

enum GradeLevel: String, CaseIterable, Identifiable {
    case preK = "Pre-K"
    case kindergarten = "Kindergarten"
    case first = "1st Grade"
    case second = "2nd Grade"
    case third = "3rd Grade"

    var id: String { rawValue }

    var ageRange: String {
        switch self {
        case .preK: return "Ages 4-5"
        case .kindergarten: return "Ages 5-6"
        case .first: return "Ages 6-7"
        case .second: return "Ages 7-8"
        case .third: return "Ages 8-9"
        }
    }
}

struct PuzzleWord: Identifiable, Hashable {
    let id = UUID()
    let answer: String
    let clue: String
    let emoji: String

    var clueImageAssetName: String {
        let lowered = answer.lowercased()
        let slug = lowered.replacingOccurrences(
            of: "[^a-z0-9]+",
            with: "_",
            options: .regularExpression
        ).trimmingCharacters(in: CharacterSet(charactersIn: "_"))

        return "clue_\(slug)"
    }
}

struct WordCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let words: [PuzzleWord]
    let isRobotCategory: Bool
}

enum GameState {
    case idle
    case playing
    case won
    case lostByTries
    case lostByTimer
}
