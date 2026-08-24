import SwiftUI

@main
struct MemoryGameApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}
import Foundation

struct Card: Identifiable {
    let id = UUID()
    let emoji: String
    var isFaceUp = false
    var isMatched = false
}

struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(radius: 3)

                Text(card.emoji)
                    .font(.largeTitle)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            }
        }
        .rotation3DEffect(
            .degrees(card.isFaceUp ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
    }
}

struct GameView: View {
    @State private var cards: [Card] = []
    @State private var score = 0
    @State private var firstFlippedIndex: Int? = nil

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Memory Game")
                .font(.largeTitle)
                .bold()

            Text("Score: \(score)")
                .font(.title2)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(cards) { card in
                    CardView(card: card)
                        .onTapGesture {
                            flip(card)
                        }
                        .frame(height: 80)
                }
            }
            .padding()

            Button("Restart Game") {
                startNewGame()
            }
            .font(.title3)
            .padding()
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .onAppear {
            startNewGame()
        }
    }

    // MARK: - Game Logic (NO CLASS)
    func startNewGame() {
        score = 0
        firstFlippedIndex = nil

        let emojis = ["🐶","🐱","🐸","🐵","🐼","🐷","🐔","🐰"]
        let deck = (emojis + emojis).shuffled()

        cards = deck.map { Card(emoji: $0) }
    }

    func flip(_ card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        guard !cards[index].isMatched else { return }
        guard !cards[index].isFaceUp else { return }

        cards[index].isFaceUp = true

        if let firstIndex = firstFlippedIndex {
            checkMatch(firstIndex, index)
            firstFlippedIndex = nil
        } else {
            firstFlippedIndex = index
        }
    }

    func checkMatch(_ first: Int, _ second: Int) {
        if cards[first].emoji == cards[second].emoji {
            cards[first].isMatched = true
            cards[second].isMatched = true
            score += 1
        } else {
            hideCardsAfterDelay(first, second)
        }
    }

    func hideCardsAfterDelay(_ first: Int, _ second: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            cards[first].isFaceUp = false
            cards[second].isFaceUp = false
        }
    }
}

