import AudioToolbox
import Combine
import Foundation
import UIKit

enum LetterButtonState {
    case fresh
    case correct
    case wrong
}

final class GameViewModel: ObservableObject {
    @Published private(set) var selectedGrade: GradeLevel?
    @Published private(set) var selectedCategory: WordCategory?
    @Published private(set) var currentPuzzle: PuzzleWord?
    @Published private(set) var gameState: GameState = .idle
    @Published private(set) var guessedLetters: Set<Character> = []
    @Published private(set) var wrongGuesses = 0
    @Published private(set) var maxWrongGuesses = 8
    @Published private(set) var usesTryLimit = true
    @Published private(set) var timerMinutes = 10
    @Published private(set) var secondsRemaining = 10 * 60

    private var usedAnswers: Set<String> = []
    private let vowels: Set<Character> = ["A", "E", "I", "O", "U"]

    var categories: [WordCategory] {
        guard let selectedGrade else { return [] }
        return GameData.categories(for: selectedGrade)
    }

    var isPlaying: Bool {
        gameState == .playing
    }

    var timerText: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var triesLeft: Int {
        guard usesTryLimit else { return Int.max }
        return max(0, maxWrongGuesses - wrongGuesses)
    }

    var triesLeftText: String {
        usesTryLimit ? "\(triesLeft)" : "∞"
    }

    var currentAnswer: String {
        currentPuzzle?.answer.uppercased() ?? ""
    }

    var uniqueAnswerLetterCount: Int {
        Set(currentAnswer.filter(\.isAlphabetic)).count
    }

    var correctLetterCount: Int {
        let answerLetters = Set(currentAnswer.filter(\.isAlphabetic))
        return guessedLetters.intersection(answerLetters).count
    }

    var removedRobotPartCount: Int {
        guard uniqueAnswerLetterCount > 0 else { return 0 }
        if correctLetterCount == 0 { return 0 }
        if gameState == .won { return 8 }

        if uniqueAnswerLetterCount >= 8 {
            return min(8, correctLetterCount)
        }

        let stepped = Int(ceil(Double(correctLetterCount) * 8.0 / Double(uniqueAnswerLetterCount)))
        return min(8, stepped)
    }

    func setTimerMinutes(_ value: Int) {
        timerMinutes = min(20, max(1, value))
        if gameState != .playing {
            resetTimer()
        }
    }

    func setMaxWrongGuesses(_ value: Int) {
        maxWrongGuesses = min(12, max(1, value))
    }

    func setUsesTryLimit(_ value: Bool) {
        usesTryLimit = value
    }

    func selectGrade(_ grade: GradeLevel) {
        selectedGrade = grade
        selectedCategory = GameData.categories(for: grade).first(where: \.isRobotCategory)
        currentPuzzle = nil
        gameState = .idle
        guessedLetters.removeAll()
        wrongGuesses = 0
        usedAnswers.removeAll()
        resetTimer()
    }

    func backToGradeSelection() {
        selectedGrade = nil
        selectedCategory = nil
        currentPuzzle = nil
        gameState = .idle
        guessedLetters.removeAll()
        wrongGuesses = 0
        usedAnswers.removeAll()
        resetTimer()
    }

    func selectCategory(_ category: WordCategory) {
        selectedCategory = category
        usedAnswers.removeAll()
        startRound()
    }

    func backToCategorySelection() {
        selectedCategory = nil
        currentPuzzle = nil
        gameState = .idle
        guessedLetters.removeAll()
        wrongGuesses = 0
        usedAnswers.removeAll()
        resetTimer()
    }

    func startRound() {
        if selectedCategory == nil, let selectedGrade {
            selectedCategory = GameData.categories(for: selectedGrade).first(where: \.isRobotCategory)
        }

        guard let selectedCategory else { return }

        let available = selectedCategory.words.filter {
            !usedAnswers.contains($0.answer.lowercased())
        }

        let source = available.isEmpty ? selectedCategory.words : available
        guard let puzzle = source.randomElement() else { return }

        currentPuzzle = puzzle
        usedAnswers.insert(puzzle.answer.lowercased())
        guessedLetters.removeAll()
        wrongGuesses = 0
        gameState = .playing
        resetTimer()
    }

    func tick() {
        guard gameState == .playing else { return }

        if secondsRemaining > 0 {
            secondsRemaining -= 1
        }

        if secondsRemaining == 0 {
            gameState = .lostByTimer
            KidSoundEffects.timeExpired()
        }
    }

    func guess(_ letter: Character) {
        guard gameState == .playing else { return }
        guard currentPuzzle != nil else { return }

        let upper = Character(String(letter).uppercased())
        guard upper.isAlphabetic else { return }

        if guessedLetters.contains(upper) {
            return
        }

        guessedLetters.insert(upper)

        if currentAnswer.contains(upper) {
            KidSoundEffects.correctGuess()
            if isWordSolved {
                gameState = .won
                KidSoundEffects.winCelebration()
            }
            return
        }

        wrongGuesses += 1
        KidSoundEffects.wrongGuess()

        if usesTryLimit, wrongGuesses >= maxWrongGuesses {
            gameState = .lostByTries
            KidSoundEffects.roundFailed()
        }
    }

    func isVowel(_ character: Character) -> Bool {
        let upper = Character(String(character).uppercased())
        return vowels.contains(upper)
    }

    func shouldReveal(_ character: Character) -> Bool {
        if !character.isAlphabetic {
            return true
        }
        if gameState != .playing {
            return true
        }
        let upper = Character(String(character).uppercased())
        return guessedLetters.contains(upper)
    }

    func buttonState(for letter: Character) -> LetterButtonState {
        let upper = Character(String(letter).uppercased())
        guard guessedLetters.contains(upper) else { return .fresh }
        return currentAnswer.contains(upper) ? .correct : .wrong
    }

    private var isWordSolved: Bool {
        for character in currentAnswer {
            if character.isAlphabetic, !guessedLetters.contains(character) {
                return false
            }
        }
        return true
    }

    private func resetTimer() {
        secondsRemaining = timerMinutes * 60
    }
}

private extension Character {
    var isAlphabetic: Bool {
        unicodeScalars.allSatisfy { CharacterSet.letters.contains($0) }
    }
}

enum KidSoundEffects {
    static func correctGuess() {
        AudioServicesPlaySystemSound(1104)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func wrongGuess() {
        AudioServicesPlaySystemSound(1053)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func winCelebration() {
        AudioServicesPlaySystemSound(1025)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func roundFailed() {
        AudioServicesPlaySystemSound(1006)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func timeExpired() {
        AudioServicesPlaySystemSound(1006)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
