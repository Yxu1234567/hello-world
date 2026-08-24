import Swift
import Foundation
import SwiftUI
import SwiftUI

struct OfflineTranslateView: View {
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var targetLanguageCode = "es"
    @State private var infoMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Offline TranslateMe")
                    .font(.largeTitle)
                    .bold()

                TextField("Enter a phrase (e.g. \"hello\", \"thank you\")",
                          text: $inputText,
                          axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...3)

                Picker("Translate to", selection: $targetLanguageCode) {
                    ForEach(languages) { lang in
                        Text("\(lang.flag) \(lang.name)").tag(lang.code)
                    }
                }
                .pickerStyle(.segmented)

                Button {
                    translateOffline()
                } label: {
                    Text("Translate (Offline)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Result:")
                        .font(.headline)

                    if !translatedText.isEmpty {
                        Text(translatedText)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("No translation yet.")
                            .foregroundColor(.secondary)
                    }
                }

                if !infoMessage.isEmpty {
                    Text(infoMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Offline Translate")
        }
    }

    func translateOffline() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            translatedText = ""
            infoMessage = "Please enter a phrase."
            return
        }

        if let result = OfflineDictionary.translate(inputText, to: targetLanguageCode) {
            translatedText = result
            if let lang = languages.first(where: { $0.code == targetLanguageCode }) {
                infoMessage = "Translated offline to \(lang.flag) \(lang.name)."
            } else {
                infoMessage = "Translated offline."
            }
        } else {
            translatedText = inputText
            infoMessage = "No offline translation found. Showing original text."
        }
    }
}


@main
struct OfflineTranslateApp: App {
    var body: some Scene {
        WindowGroup {
            OfflineTranslateView()
        }
    }
}


struct Language: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
}

let languages: [Language] = [
    Language(name: "Spanish",    code: "es", flag: "🇪🇸"),
    Language(name: "French",     code: "fr", flag: "🇫🇷"),
    Language(name: "German",     code: "de", flag: "🇩🇪"),
    Language(name: "Italian",    code: "it", flag: "🇮🇹")
]

// Simple offline phrase dictionary: English → target language
struct OfflineDictionary {
    // key: English phrase (lowercased)
    // value: [languageCode: translation]
    static let translations: [String: [String: String]] = [
        "hello": [
            "es": "hola",
            "fr": "bonjour",
            "de": "hallo",
            "it": "ciao"
        ],
        "thank you": [
            "es": "gracias",
            "fr": "merci",
            "de": "danke",
            "it": "grazie"
        ],
        "good morning": [
            "es": "buenos días",
            "fr": "bonjour",
            "de": "guten Morgen",
            "it": "buongiorno"
        ],
        "good night": [
            "es": "buenas noches",
            "fr": "bonne nuit",
            "de": "gute Nacht",
            "it": "buonanotte"
        ],
        "how are you": [
            "es": "¿cómo estás?",
            "fr": "comment ça va ?",
            "de": "wie geht es dir?",
            "it": "come stai?"
        ]
    ]

    static func translate(_ text: String, to targetCode: String) -> String? {
        let key = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return translations[key]?[targetCode]
    }
}




