import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var showRobotPlay = false
    @State private var showRoundSetup = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.07, blue: 0.12), Color(red: 0.08, green: 0.12, blue: 0.19)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Group {
                if viewModel.selectedGrade == nil {
                    GradeSelectionView(viewModel: viewModel) { selectedGrade in
                        viewModel.selectGrade(selectedGrade)
                        showRobotPlay = true
                        showRoundSetup = false
                    }
                } else if showRobotPlay {
                    RobotPlayView(
                        gradeName: viewModel.selectedGrade?.rawValue ?? "",
                        onBack: {
                            viewModel.backToGradeSelection()
                            showRobotPlay = false
                            showRoundSetup = false
                        },
                        onPlay: {
                            showRobotPlay = false
                            showRoundSetup = true
                        }
                    )
                } else if showRoundSetup {
                    RoundSetupView(
                        viewModel: viewModel,
                        onBack: {
                            showRobotPlay = true
                            showRoundSetup = false
                        },
                        onStart: {
                            viewModel.startRound()
                            showRoundSetup = false
                        }
                    )
                } else {
                    GameScreenView(
                        viewModel: viewModel,
                        onBackToSetup: {
                            showRoundSetup = true
                        },
                        onBackToGrade: {
                            viewModel.backToGradeSelection()
                            showRobotPlay = false
                            showRoundSetup = false
                        }
                    )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
}

private struct GradeSelectionView: View {
    @ObservedObject var viewModel: GameViewModel
    let onGradeSelected: (GradeLevel) -> Void

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
                            onGradeSelected(grade)
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

private struct RobotPlayView: View {
    let gradeName: String
    let onBack: () -> Void
    let onPlay: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Button(action: onBack) {
                    Label("Grades", systemImage: "chevron.left")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)

                Spacer()

                Text(gradeName)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Color(red: 0.55, green: 0.83, blue: 1.00))
            }

            Spacer(minLength: 8)

            Text("Robot Rob")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.98, green: 0.33, blue: 0.34))

            RobotRobEnhancedView(height: 315)

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

            Spacer(minLength: 6)
        }
    }
}

private struct RoundSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    let onBack: () -> Void
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Button(action: onBack) {
                        Label("Robot Rob", systemImage: "chevron.left")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)

                    Spacer()

                    Text(viewModel.selectedGrade?.rawValue ?? "")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.83, blue: 1.00))
                }

                HStack {
                    Text("Round Setup")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Spacer()
                }

                TimerControlCard(
                    minutes: Binding(
                        get: { viewModel.timerMinutes },
                        set: { viewModel.setTimerMinutes($0) }
                    )
                )

                TriesControlCard(
                    usesTryLimit: Binding(
                        get: { viewModel.usesTryLimit },
                        set: { viewModel.setUsesTryLimit($0) }
                    ),
                    tries: Binding(
                        get: { viewModel.maxWrongGuesses },
                        set: { viewModel.setMaxWrongGuesses($0) }
                    )
                )

                Button(action: onStart) {
                    Text("Start Round")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.11, green: 0.84, blue: 0.55))
                        )
                        .foregroundStyle(.black)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
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
    let onBackToSetup: () -> Void
    let onBackToGrade: () -> Void

    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private let keyboardColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Button {
                        onBackToSetup()
                    } label: {
                        Label("Setup", systemImage: "chevron.left")
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
                    StatChip(
                        title: viewModel.usesTryLimit ? "Tries Left" : "Try Limit",
                        value: viewModel.usesTryLimit ? viewModel.triesLeftText : "Off",
                        color: Color(red: 0.89, green: 0.28, blue: 0.29)
                    )
                    StatChip(title: "Goal", value: "Erase Rob", color: Color(red: 0.11, green: 0.72, blue: 0.50))
                }

                RobotDisassemblyView(
                    removedPartCount: viewModel.removedRobotPartCount,
                    correctLetters: viewModel.correctLetterCount,
                    totalLetters: viewModel.uniqueAnswerLetterCount,
                    wrongGuesses: viewModel.wrongGuesses,
                    maxWrongGuesses: viewModel.maxWrongGuesses,
                    usesTryLimit: viewModel.usesTryLimit
                )

                if let puzzle = viewModel.currentPuzzle {
                    ClueCard(puzzle: puzzle)
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
                                .foregroundStyle(keyTextColor(for: letter))
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
                            onBackToSetup()
                        } label: {
                            Text("Settings")
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

                        Button {
                            onBackToGrade()
                        } label: {
                            Text("Grades")
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(red: 0.94, green: 0.76, blue: 0.30))
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
            return "Erase Robot Rob Parts!"
        case .won:
            return "Robot Rob Fully Erased!"
        case .lostByTries:
            return "Out Of Tries"
        case .lostByTimer:
            return "Time Is Up"
        }
    }

    private var statusSubtitle: String {
        switch viewModel.gameState {
        case .idle, .playing:
            return "Each correct letter removes parts in order until Rob is gone."
        case .won:
            return "Awesome! You solved the word and erased every part."
        case .lostByTries:
            return "You used all tries. Adjust settings and try again."
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

    private func keyTextColor(for letter: Character) -> Color {
        viewModel.isVowel(letter)
            ? Color(red: 0.13, green: 0.45, blue: 0.95)
            : .black
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

private struct RobotDisassemblyView: View {
    private enum RobotPart: CaseIterable {
        case leftAntenna
        case rightAntenna
        case leftArm
        case rightArm
        case leftLeg
        case rightLeg
        case body
        case head
    }

    let removedPartCount: Int
    let correctLetters: Int
    let totalLetters: Int
    let wrongGuesses: Int
    let maxWrongGuesses: Int
    let usesTryLimit: Bool

    var body: some View {
        let removed = min(max(removedPartCount, 0), RobotPart.allCases.count)

        VStack(spacing: 6) {
            Text("Robot Rob Erase Meter")
                .font(.system(size: 23, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Correct Letters: \(correctLetters)/\(max(1, totalLetters))")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.60, green: 0.86, blue: 1.00))

            if usesTryLimit {
                Text("Wrong Guesses: \(wrongGuesses)/\(maxWrongGuesses)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 1.00, green: 0.64, blue: 0.66))
            } else {
                Text("Wrong Guesses: \(wrongGuesses)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 1.00, green: 0.64, blue: 0.66))
            }

            ZStack {
                Image("robot_rob_split")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: 240, height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                GeometryReader { geometry in
                    ForEach(Array(RobotPart.allCases.enumerated()), id: \.offset) { index, part in
                        if index < removed {
                            partMaskView(for: part, in: geometry.size)
                                .blendMode(.destinationOut)
                        }
                    }
                }
                .frame(width: 240, height: 360)
            }
            .compositingGroup()
            .animation(.easeInOut(duration: 0.35), value: removed)
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

    @ViewBuilder
    private func partMaskView(for part: RobotPart, in size: CGSize) -> some View {
        switch part {
        case .leftAntenna:
            Circle()
                .fill(Color.white)
                .frame(width: size.width * 0.15, height: size.width * 0.15)
                .position(x: size.width * 0.38, y: size.height * 0.86)
        case .rightAntenna:
            Circle()
                .fill(Color.white)
                .frame(width: size.width * 0.15, height: size.width * 0.15)
                .position(x: size.width * 0.63, y: size.height * 0.86)
        case .leftArm:
            RoundedRectangle(cornerRadius: size.width * 0.10)
                .fill(Color.white)
                .frame(width: size.width * 0.26, height: size.height * 0.26)
                .position(x: size.width * 0.16, y: size.height * 0.47)
        case .rightArm:
            RoundedRectangle(cornerRadius: size.width * 0.10)
                .fill(Color.white)
                .frame(width: size.width * 0.26, height: size.height * 0.26)
                .position(x: size.width * 0.84, y: size.height * 0.47)
        case .leftLeg:
            RoundedRectangle(cornerRadius: size.width * 0.10)
                .fill(Color.white)
                .frame(width: size.width * 0.25, height: size.height * 0.31)
                .position(x: size.width * 0.26, y: size.height * 0.69)
        case .rightLeg:
            RoundedRectangle(cornerRadius: size.width * 0.10)
                .fill(Color.white)
                .frame(width: size.width * 0.25, height: size.height * 0.31)
                .position(x: size.width * 0.74, y: size.height * 0.69)
        case .body:
            RoundedRectangle(cornerRadius: size.width * 0.08)
                .fill(Color.white)
                .frame(width: size.width * 0.48, height: size.height * 0.18)
                .position(x: size.width * 0.50, y: size.height * 0.46)
        case .head:
            RoundedRectangle(cornerRadius: size.width * 0.10)
                .fill(Color.white)
                .frame(width: size.width * 0.72, height: size.height * 0.26)
                .position(x: size.width * 0.50, y: size.height * 0.16)
        }
    }
}

private struct ClueCard: View {
    let puzzle: PuzzleWord

    var body: some View {
        VStack(spacing: 8) {
            Text("Hint")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(normalizedHint(puzzle.clue))
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

    private func normalizedHint(_ clue: String) -> String {
        let words = clue
            .replacingOccurrences(of: "[^A-Za-z0-9 ]+", with: " ", options: .regularExpression)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)

        if words.count >= 5, words.count <= 10 {
            return words.joined(separator: " ")
        }

        if words.count < 5 {
            var padded = words
            let filler = ["think", "carefully", "about", "this", "word"]
            var index = 0
            while padded.count < 5 {
                padded.append(filler[index % filler.count])
                index += 1
            }
            return padded.joined(separator: " ")
        }

        return words.prefix(10).joined(separator: " ")
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

private struct TriesControlCard: View {
    @Binding var usesTryLimit: Bool
    @Binding var tries: Int

    var body: some View {
        VStack(spacing: 10) {
            Toggle(isOn: $usesTryLimit) {
                Text("Use Try Limit")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .toggleStyle(.switch)
            .tint(Color(red: 0.95, green: 0.34, blue: 0.36))

            if usesTryLimit {
                Stepper {
                    Text("\(tries) tries")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 1.00, green: 0.64, blue: 0.66))
                } onIncrement: {
                    tries = min(12, tries + 1)
                } onDecrement: {
                    tries = max(1, tries - 1)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.13, green: 0.17, blue: 0.27))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.95, green: 0.34, blue: 0.36), lineWidth: 2.5)
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

            Image("robot_rob")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .saturation(1.05)
                .contrast(1.03)
                .shadow(color: Color(red: 0.41, green: 0.80, blue: 1.00).opacity(0.25), radius: 10, x: 0, y: 5)
        }
        .frame(height: height)
    }
}
