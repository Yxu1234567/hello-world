import SwiftUI

import SwiftUI

@main
struct TriviaGameApp: App {
    var body: some Scene {
        WindowGroup {
            TriviaGameView()
        }
    }
}

import Foundation

struct TriviaResponse: Codable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable, Identifiable {
    var id: UUID { UUID() }
    let category: String
    let type: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]

    var allAnswers: [String] {
        (incorrect_answers + [correct_answer]).shuffled()
    }
}

import Foundation

struct TriviaAPI {
    static func fetchQuestions() async throws -> [TriviaQuestion] {
        let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(TriviaResponse.self, from: data)
        return decoded.results
    }
}


import SwiftUI

struct TriviaGameView: View {
    @State private var questions: [TriviaQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: String? = nil
    @State private var showNextButton = false
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading Trivia…")
                    .task {
                        await loadQuestions()
                    }
            } else if currentIndex < questions.count {
                let q = questions[currentIndex]

                Text("Trivia Challenge")
                    .font(.largeTitle)
                    .bold()

                Text("Score: \(score)")
                    .font(.title2)

                Text(q.question.decodingHTMLEntities())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()

                ForEach(q.allAnswers, id: \.self) { answer in
                    AnswerButton(
                        text: answer.decodingHTMLEntities(),
                        isCorrect: answer == q.correct_answer,
                        isSelected: selectedAnswer == answer
                    ) {
                        handleAnswer(answer, correct: q.correct_answer)
                    }
                }

                if showNextButton {
                    Button("Next Question") {
                        nextQuestion()
                    }
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                Spacer()
            } else {
                Text("Game Over!")
                    .font(.largeTitle)
                    .bold()

                Text("Final Score: \(score) / \(questions.count)")
                    .font(.title2)

                Button("Play Again") {
                    resetGame()
                }
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }

    // MARK: - Game Logic

    func loadQuestions() async {
        do {
            questions = try await TriviaAPI.fetchQuestions()
            isLoading = false
        } catch {
            print("Error loading trivia:", error)
        }
    }

    func handleAnswer(_ answer: String, correct: String) {
        guard selectedAnswer == nil else { return }

        selectedAnswer = answer
        showNextButton = true

        if answer == correct {
            score += 1
        }
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswer = nil
        showNextButton = false
    }

    func resetGame() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showNextButton = false
        isLoading = true

        Task {
            await loadQuestions()
        }
    }
}

import SwiftUI

struct AnswerButton: View {
    let text: String
    let isCorrect: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding()
                .frame(maxWidth: .infinity)
                .background(backgroundColor)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(isSelected)
    }

    var backgroundColor: Color {
        if !isSelected {
            return Color.blue.opacity(0.8)
        }
        return isCorrect ? .green : .red
    }
}


import Foundation

extension String {
    func decodingHTMLEntities() -> String {
        var result = self

        let entities: [String: String] = [
            "&quot;": "\"",
            "&#039;": "'",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&ldquo;": "“",
            "&rdquo;": "”"
        ]

        for (entity, character) in entities {
            result = result.replacingOccurrences(of: entity, with: character)
        }

        return result
    }
}






