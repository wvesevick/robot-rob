import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var hasStarted = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.07, blue: 0.12), Color(red: 0.08, green: 0.12, blue: 0.19)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                if !hasStarted {
                    StartScreenView {
                        hasStarted = true
                    }
                } else if viewModel.selectedGrade == nil {
                    GradeSelectionView(viewModel: viewModel)
                } else if viewModel.selectedCategory == nil {
                    CategorySelectionView(viewModel: viewModel)
                } else {
                    GameScreenView(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
}

private struct StartScreenView: View {
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 20)

            Text("Robot Rob")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.98, green: 0.33, blue: 0.34))

            RobotRobEnhancedView(height: 310)

            Button(action: onPlay) {
                Text("Play!")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.11, green: 0.84, blue: 0.55))
                    )
                    .foregroundStyle(.black)
            }
            .buttonStyle(.plain)

            Spacer()
        }
    }
}

private struct GradeSelectionView: View {
    @ObservedObject var viewModel: GameViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text("Choose Your Grade")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(GradeLevel.allCases) { grade in
                        Button {
                            viewModel.selectGrade(grade)
                        } label: {
                            Text(grade.rawValue)
                                .font(.system(size: 21, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color(red: 0.93, green: 0.27, blue: 0.30), lineWidth: 2.5)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }
}

private struct CategorySelectionView: View {
    @ObservedObject var viewModel: GameViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Button {
                        viewModel.backToGradeSelection()
                    } label: {
                        Label("Grades", systemImage: "chevron.left")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)

                    Spacer()

                    Text(viewModel.selectedGrade?.rawValue ?? "")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.83, blue: 1.00))
                }

                TimerControlCard(
                    minutes: Binding(
                        get: { viewModel.timerMinutes },
                        set: { viewModel.setTimerMinutes($0) }
                    )
                )

                HStack {
                    Text("Categories")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        Button {
                            viewModel.selectCategory(category)
                        } label: {
                            VStack(spacing: 10) {
                                CategoryPreviewImage(category: category)
                                    .frame(height: 106)

                                Text(category.name)
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                category.isRobotCategory
                                                ? Color(red: 0.95, green: 0.34, blue: 0.36)
                                                : Color(red: 0.43, green: 0.77, blue: 1.00),
                                                lineWidth: 2.5
                                            )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
}

private struct GameScreenView: View {
    @ObservedObject var viewModel: GameViewModel

    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private let keyboardColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Button {
                        viewModel.backToCategorySelection()
                    } label: {
                        Label("Categories", systemImage: "chevron.left")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)

                    Spacer()

                    Text(viewModel.selectedGrade?.rawValue ?? "")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.83, blue: 1.00))
                }

                HStack(spacing: 10) {
                    StatChip(title: "Timer", value: viewModel.timerText, color: Color(red: 0.13, green: 0.44, blue: 0.88))
                    StatChip(title: "Tries Left", value: "\(viewModel.triesLeft)", color: Color(red: 0.89, green: 0.28, blue: 0.29))
                    StatChip(title: "Goal", value: "Vanish Rob", color: Color(red: 0.11, green: 0.72, blue: 0.50))
                }

                VanishingRobotView(
                    vanishStep: viewModel.vanishStep,
                    correctLetters: viewModel.correctLetterCount,
                    totalLetters: viewModel.uniqueAnswerLetterCount,
                    wrongGuesses: viewModel.wrongGuesses
                )

                if let puzzle = viewModel.currentPuzzle {
                    ClueCard(
                        puzzle: puzzle,
                        isRobotCategory: viewModel.selectedCategory?.isRobotCategory ?? false
                    )
                }

                WordTilesView(viewModel: viewModel)

                LazyVGrid(columns: keyboardColumns, spacing: 8) {
                    ForEach(letters, id: \.self) { letter in
                        Button {
                            viewModel.guess(letter)
                        } label: {
                            Text(String(letter))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(keyColor(for: letter))
                                )
                                .foregroundStyle(.black)
                        }
                        .buttonStyle(.plain)
                        .disabled(!viewModel.isPlaying || viewModel.buttonState(for: letter) != .fresh)
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                )

                statusCard

                if viewModel.gameState != .playing {
                    HStack(spacing: 10) {
                        Button {
                            viewModel.startRound()
                        } label: {
                            Text(viewModel.gameState == .won ? "Next Word" : "Try New Word")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(red: 0.11, green: 0.84, blue: 0.55))
                                )
                                .foregroundStyle(.black)
                        }
                        .buttonStyle(.plain)

                        Button {
                            viewModel.backToCategorySelection()
                        } label: {
                            Text("New Category")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(red: 0.45, green: 0.78, blue: 1.00))
                                )
                                .foregroundStyle(.black)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .onReceive(timer) { _ in
            viewModel.tick()
        }
    }

    private var statusCard: some View {
        VStack(spacing: 6) {
            Text(statusTitle)
                .font(.system(size: 21, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            if let puzzle = viewModel.currentPuzzle {
                Text("Word: \(puzzle.answer.uppercased())")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(viewModel.gameState == .playing ? 0.0 : 0.75))
            }

            Text(statusSubtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(statusColor.opacity(0.9), lineWidth: 2.5)
                )
        )
    }

    private var statusTitle: String {
        switch viewModel.gameState {
        case .idle, .playing:
            return "Make Robot Rob Vanish!"
        case .won:
            return "Robot Rob Vanished!"
        case .lostByTries:
            return "Out Of Tries"
        case .lostByTimer:
            return "Time Is Up"
        }
    }

    private var statusSubtitle: String {
        switch viewModel.gameState {
        case .idle, .playing:
            return "Correct letters make Rob disappear. Wrong letters only use tries."
        case .won:
            return "Awesome! You finished the word and made Rob vanish."
        case .lostByTries:
            return "You used all 10 tries. Start a new word and try again."
        case .lostByTimer:
            return "You ran out of time. Try another round."
        }
    }

    private var statusColor: Color {
        switch viewModel.gameState {
        case .idle, .playing:
            return Color(red: 0.43, green: 0.77, blue: 1.00)
        case .won:
            return Color(red: 0.11, green: 0.84, blue: 0.55)
        case .lostByTries, .lostByTimer:
            return Color(red: 0.89, green: 0.28, blue: 0.29)
        }
    }

    private func keyColor(for letter: Character) -> Color {
        switch viewModel.buttonState(for: letter) {
        case .fresh:
            return Color(red: 0.95, green: 0.83, blue: 0.33)
        case .correct:
            return Color(red: 0.53, green: 0.90, blue: 0.63)
        case .wrong:
            return Color(red: 1.00, green: 0.63, blue: 0.64)
        }
    }
}

private struct WordTilesView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        let letters = Array(viewModel.currentAnswer)

        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 34), spacing: 8)],
            spacing: 8
        ) {
            ForEach(Array(letters.enumerated()), id: \.offset) { _, character in
                let revealed = viewModel.shouldReveal(character)
                let isLetter = character.unicodeScalars.allSatisfy { CharacterSet.letters.contains($0) }
                let display = revealed ? String(character) : "_"

                Text(display)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .frame(width: 36, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 9)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color.black.opacity(0.20), lineWidth: 2)
                    )
                    .foregroundStyle(letterColor(isLetter: isLetter, revealed: revealed, character: character))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.11, green: 0.14, blue: 0.22))
        )
    }

    private func letterColor(isLetter: Bool, revealed: Bool, character: Character) -> Color {
        guard isLetter else { return .black }
        guard revealed else { return .black.opacity(0.45) }
        return viewModel.isVowel(character)
            ? Color(red: 0.13, green: 0.45, blue: 0.95)
            : .black
    }
}

private struct VanishingRobotView: View {
    let vanishStep: Int
    let correctLetters: Int
    let totalLetters: Int
    let wrongGuesses: Int

    var body: some View {
        let stageOpacity: Double = {
            if vanishStep >= 10 { return 0.0 }
            if vanishStep == 9 { return 0.30 }
            return 1.0
        }()

        let stageScale: CGFloat = {
            if vanishStep >= 10 { return 0.45 }
            if vanishStep == 9 { return 0.80 }
            return 1.0
        }()

        VStack(spacing: 6) {
            Text("Robot Rob Vanish Meter")
                .font(.system(size: 23, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Correct Letters: \(correctLetters)/\(max(1, totalLetters))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.60, green: 0.86, blue: 1.00))

            Text("Wrong Guesses: \(wrongGuesses)/10")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 1.00, green: 0.64, blue: 0.66))

            VStack(spacing: -4) {
                ZStack {
                    robotPart("robot_left_antenna", hideAt: 1, width: 28)
                        .offset(x: -60, y: -24)
                    robotPart("robot_right_antenna", hideAt: 2, width: 28)
                        .offset(x: 60, y: -24)
                    robotPart("robot_head", hideAt: 5, width: 132)
                }

                HStack(spacing: 8) {
                    robotPart("robot_left_arm", hideAt: 3, width: 52)
                    robotPart("robot_body", hideAt: 6, width: 128)
                    robotPart("robot_right_arm", hideAt: 4, width: 52)
                }

                HStack(spacing: 44) {
                    robotPart("robot_left_leg", hideAt: 7, width: 42)
                    robotPart("robot_right_leg", hideAt: 8, width: 42)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
            .opacity(stageOpacity)
            .scaleEffect(stageScale)
            .animation(.easeInOut(duration: 0.35), value: vanishStep)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.95, green: 0.34, blue: 0.36), lineWidth: 2.5)
                )
        )
    }

    private func robotPart(_ asset: String, hideAt threshold: Int, width: CGFloat) -> some View {
        Image(asset)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: width)
            .saturation(1.3)
            .contrast(1.1)
            .opacity(vanishStep >= threshold ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: vanishStep)
    }
}

private struct ClueCard: View {
    let puzzle: PuzzleWord
    let isRobotCategory: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Image(puzzle.clueImageAssetName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if isRobotCategory {
                    HStack(spacing: 4) {
                        Image("robot_head")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        Text("Robot Rob")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.95))
                            .overlay(
                                Capsule()
                                    .stroke(Color(red: 0.93, green: 0.31, blue: 0.33), lineWidth: 2)
                            )
                    )
                    .padding(8)
                }
            }

            Text("Clue")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Text(puzzle.clue)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.43, green: 0.77, blue: 1.00), lineWidth: 2.5)
                )
        )
    }
}

private struct TimerControlCard: View {
    @Binding var minutes: Int

    var body: some View {
        HStack {
            Text("Timer")
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Stepper {
                Text("\(minutes) min")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.55, green: 0.83, blue: 1.00))
            } onIncrement: {
                minutes = min(20, minutes + 1)
            } onDecrement: {
                minutes = max(1, minutes - 1)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.43, green: 0.77, blue: 1.00), lineWidth: 2.5)
                )
        )
    }
}

private struct StatChip: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.92))
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color)
        )
    }
}

private struct CategoryPreviewImage: View {
    let category: WordCategory

    var body: some View {
        Group {
            if category.isRobotCategory {
                RobotRobEnhancedView(height: 106)
            } else {
                Image(category.previewImageAssetName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.09, green: 0.11, blue: 0.18))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct RobotRobEnhancedView: View {
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.10, blue: 0.17), Color(red: 0.10, green: 0.16, blue: 0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(red: 0.91, green: 0.28, blue: 0.30), lineWidth: 2)
                )

            VStack(spacing: -4) {
                ZStack {
                    robotPiece("robot_left_antenna", width: 30)
                        .offset(x: -58, y: -26)
                    robotPiece("robot_right_antenna", width: 30)
                        .offset(x: 58, y: -26)
                    robotPiece("robot_head", width: 138)
                }

                HStack(spacing: 8) {
                    robotPiece("robot_left_arm", width: 56)
                    robotPiece("robot_body", width: 134)
                    robotPiece("robot_right_arm", width: 56)
                }

                HStack(spacing: 46) {
                    robotPiece("robot_left_leg", width: 44)
                    robotPiece("robot_right_leg", width: 44)
                }
            }
            .padding(.top, 6)
            .shadow(color: Color(red: 0.41, green: 0.80, blue: 1.00).opacity(0.25), radius: 10, x: 0, y: 5)
        }
        .frame(height: height)
    }

    private func robotPiece(_ asset: String, width: CGFloat) -> some View {
        Image(asset)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: width)
            .saturation(1.35)
            .contrast(1.12)
            .brightness(0.02)
    }
}
