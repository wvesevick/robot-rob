import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.96, green: 0.98, blue: 1.00), Color(red: 1.00, green: 0.97, blue: 0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                if viewModel.selectedGrade == nil {
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

private struct GradeSelectionView: View {
    @ObservedObject var viewModel: GameViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Robot Rob")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.85, green: 0.17, blue: 0.17))
                    Text("Vanishing Man")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(red: 0.14, green: 0.30, blue: 0.79))
                    Text("Pick your grade and start a fun word mission.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black.opacity(0.75))
                }
                .padding(.top, 8)

                RobotHeroCard()

                TimerControlCard(
                    title: "Round Timer",
                    subtitle: "Default is 10 minutes. You can adjust this anytime before a round.",
                    minutes: Binding(
                        get: { viewModel.timerMinutes },
                        set: { viewModel.setTimerMinutes($0) }
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("What grade are you in?")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(GradeLevel.allCases) { grade in
                            Button {
                                viewModel.selectGrade(grade)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(grade.rawValue)
                                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                                    Text(grade.ageRange)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.black.opacity(0.65))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 18)
                                                .stroke(Color(red: 0.99, green: 0.80, blue: 0.24), lineWidth: 3)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .funCard()

                Link("Privacy Policy", destination: URL(string: "https://wvesevick.github.io/robot-rob/privacy-policy.html")!)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.11, green: 0.44, blue: 0.88))
            }
            .padding(.bottom, 20)
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

                    Spacer()

                    Text(viewModel.selectedGrade?.rawValue ?? "")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.28, blue: 0.76))
                }

                VStack(spacing: 8) {
                    Text("Choose a Category")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                    Text("Robot Rob Mystery includes mixed words for this grade.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.black.opacity(0.7))
                }
                .funCard()

                TimerControlCard(
                    title: "Timer",
                    subtitle: "How long should each round be?",
                    minutes: Binding(
                        get: { viewModel.timerMinutes },
                        set: { viewModel.setTimerMinutes($0) }
                    )
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        Button {
                            viewModel.selectCategory(category)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.icon)
                                    .font(.system(size: category.isRobotCategory ? 38 : 30))
                                Text(category.name)
                                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.black)
                                    .multilineTextAlignment(.leading)
                                Text(category.description)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                category.isRobotCategory
                                                ? Color(red: 0.93, green: 0.28, blue: 0.30)
                                                : Color(red: 0.14, green: 0.52, blue: 0.95),
                                                lineWidth: 3
                                            )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 20)
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

                    Spacer()

                    Text(viewModel.selectedCategory?.name ?? "")
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.12, green: 0.30, blue: 0.77))
                }

                HStack(spacing: 10) {
                    StatChip(title: "Timer", value: viewModel.timerText, color: Color(red: 0.14, green: 0.49, blue: 0.95))
                    StatChip(title: "Tries Left", value: "\(viewModel.triesLeft)", color: Color(red: 0.88, green: 0.25, blue: 0.24))
                    StatChip(title: "Goal", value: "Guess Word", color: Color(red: 0.21, green: 0.64, blue: 0.39))
                }

                VanishingRobotView(wrongGuesses: viewModel.wrongGuesses)

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
                                        .fill(color(for: letter))
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
                        .fill(.white)
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
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
                                        .fill(Color(red: 0.99, green: 0.82, blue: 0.18))
                                )
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
                                        .fill(Color(red: 0.31, green: 0.78, blue: 0.95))
                                )
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
            if let puzzle = viewModel.currentPuzzle {
                Text("Word: \(puzzle.answer.uppercased())")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.black.opacity(viewModel.gameState == .playing ? 0.0 : 0.72))
            }
            Text(statusSubtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.black.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(statusColor.opacity(0.8), lineWidth: 3)
                )
        )
    }

    private var statusTitle: String {
        switch viewModel.gameState {
        case .idle, .playing:
            return "Keep Going!"
        case .won:
            return "You Saved Robot Rob!"
        case .lostByTries:
            return "Robot Rob Vanished!"
        case .lostByTimer:
            return "Time Is Up!"
        }
    }

    private var statusSubtitle: String {
        switch viewModel.gameState {
        case .idle, .playing:
            return "Vowels show in color and consonants are black."
        case .won:
            return "Awesome job! Grab another word mission."
        case .lostByTries:
            return "No worries. Start a new round and rebuild Rob."
        case .lostByTimer:
            return "Try a faster round or add more timer minutes."
        }
    }

    private var statusColor: Color {
        switch viewModel.gameState {
        case .idle, .playing:
            return Color(red: 0.13, green: 0.50, blue: 0.92)
        case .won:
            return Color(red: 0.17, green: 0.67, blue: 0.38)
        case .lostByTries, .lostByTimer:
            return Color(red: 0.88, green: 0.24, blue: 0.26)
        }
    }

    private func color(for letter: Character) -> Color {
        switch viewModel.buttonState(for: letter) {
        case .fresh:
            return Color(red: 0.99, green: 0.89, blue: 0.45)
        case .correct:
            return Color(red: 0.52, green: 0.90, blue: 0.62)
        case .wrong:
            return Color(red: 1.00, green: 0.62, blue: 0.62)
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
                            .stroke(Color.black.opacity(0.22), lineWidth: 2)
                    )
                    .foregroundStyle(letterColor(isLetter: isLetter, revealed: revealed, character: character))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.99, blue: 0.96))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
        )
    }

    private func letterColor(isLetter: Bool, revealed: Bool, character: Character) -> Color {
        guard isLetter else { return .black }
        guard revealed else { return .black.opacity(0.45) }
        return viewModel.isVowel(character)
            ? Color(red: 0.15, green: 0.44, blue: 0.95)
            : .black
    }
}

private struct VanishingRobotView: View {
    let wrongGuesses: Int

    var body: some View {
        let stageOpacity: Double = {
            if wrongGuesses >= 10 { return 0.0 }
            if wrongGuesses == 9 { return 0.35 }
            return 1.0
        }()

        let stageScale: CGFloat = {
            if wrongGuesses >= 10 { return 0.50 }
            if wrongGuesses == 9 { return 0.82 }
            return 1.0
        }()

        VStack(spacing: 6) {
            Text("Robot Rob")
                .font(.system(size: 24, weight: .black, design: .rounded))
            Text("Wrong Guesses: \(wrongGuesses)/10")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.7))

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
            .animation(.easeInOut(duration: 0.35), value: wrongGuesses)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.93, green: 0.24, blue: 0.25), lineWidth: 3)
                )
                .shadow(color: .black.opacity(0.07), radius: 6, x: 0, y: 4)
        )
    }

    private func robotPart(_ asset: String, hideAt threshold: Int, width: CGFloat) -> some View {
        Image(asset)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: width)
            .opacity(wrongGuesses >= threshold ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 0.25), value: wrongGuesses)
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
                    .frame(height: 180)
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
                                    .stroke(Color(red: 0.92, green: 0.27, blue: 0.27), lineWidth: 2)
                            )
                    )
                    .padding(8)
                }
            }

            Text("Clue")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.black.opacity(0.55))
            Text(puzzle.clue)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 1.0, green: 0.99, blue: 0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.23, green: 0.61, blue: 0.95), lineWidth: 2.5)
                )
        )
    }
}

private struct RobotHeroCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("robot_reference")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text("Help Robot Rob stay together by guessing words!")
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.black.opacity(0.8))
        }
        .funCard(border: Color(red: 0.21, green: 0.63, blue: 0.93))
    }
}

private struct TimerControlCard: View {
    let title: String
    let subtitle: String
    @Binding var minutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .black, design: .rounded))
            Text(subtitle)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.black.opacity(0.7))

            Stepper {
                Text("\(minutes) minute\(minutes == 1 ? "" : "s")")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.14, green: 0.44, blue: 0.92))
            } onIncrement: {
                minutes = min(20, minutes + 1)
            } onDecrement: {
                minutes = max(1, minutes - 1)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.96, green: 0.98, blue: 1.00))
            )
        }
        .funCard()
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

private extension View {
    func funCard(border: Color = Color(red: 0.98, green: 0.76, blue: 0.22)) -> some View {
        self
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(border, lineWidth: 3)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 7, x: 0, y: 4)
            )
    }
}
