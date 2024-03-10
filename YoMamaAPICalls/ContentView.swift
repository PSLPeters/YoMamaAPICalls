//
//  ContentView.swift
//  YoMamaAPICalls
//
//  Created by Michael Peters on 3/9/24.
//

import SwiftUI
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
let jokeReader = JokeReader()

struct ContentView: View {
    @State private var joke = ""
    @State private var category = ""
    @State private var categorystring = ""
    @State private var isJokeCopied = false
    
    @AppStorage("isDarkModeOn") var isDarkModeOn = false
    
    struct Categories : Identifiable {
        let id = UUID()
        let name : String
    }
    let arrCategories =
        [
            Categories(name: "Bald"),
            Categories(name: "Fat"),
            Categories(name: "Hairy"),
            Categories(name: "Nasty"),
            Categories(name: "Old"),
            Categories(name: "Poor"),
            Categories(name: "Stupid"),
            Categories(name: "Short"),
            Categories(name: "Skinny"),
            Categories(name: "Tall"),
            Categories(name: "Ugly"),
        ]
    
    @AppStorage("selectedScheme") private var selectedCategory = 0
    @AppStorage("isSiriOn") var isSiriOn = false
    
    var body: some View {
        
        HStack {
            Button {
                isDarkModeOn.toggle()
            } label: {
                let image = isDarkModeOn ? "lightbulb" : "lightbulb.fill"
                Image(systemName: image)
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            Button {
                isSiriOn.toggle()
                if isSiriOn == false
                {
                    jokeReader.stopReading()
                }
            } label: {
                let image = isSiriOn ? "waveform.circle.fill" : "waveform.circle"
                Image(systemName: image)
            }
            Spacer()
            Text("Yo Mama Jokes")
                .font(.title)
                .bold()
            Spacer()
        }
        Divider()
        HStack {
            Text("Category:")
                .padding(.trailing, -80)
            Spacer()
            Picker("Select Profile", selection: $selectedCategory) {
                ForEach(arrCategories.indices, id:\.self) { index in
                    let foundCategory = arrCategories[index]
                    Text((foundCategory.name))
                        .tag(index)
                }
            }
            .pickerStyle(.menu)
            .padding(.trailing, 80)
            Spacer()
            Button(action: {
                UIPasteboard.general.string = joke
                isJokeCopied = true
            }, label: {
                Text(isJokeCopied ? "Copied!" : "Copy Joke")
            })
            .disabled(joke.isEmpty || isJokeCopied)
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        Divider()
        VStack {
            Spacer()
            Text(joke)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
            Spacer()
            Divider()
            Button {
                Task {
                    jokeReader.stopReading()
                    let (data, _) = try await URLSession.shared.data(from: URL(string:"https://www.yomama-jokes.com/api/v1/jokes/\(arrCategories[selectedCategory].name)/random/")!)
                    let decodedResponse = try? JSONDecoder().decode(user.self, from: data)
                    joke = decodedResponse?.joke ?? ""
                    category = decodedResponse?.category ?? ""
                    if isSiriOn
                    {
                        jokeReader.readJoke(joke, withVoice: "en-US", atRate: 1.0)
                    }
                    isJokeCopied = false
                }
            } label: {
                Text("\(isSiriOn ? "Read" : "Load") me a joke!")
            }
            .padding(.top, 15)
        }
        .preferredColorScheme(isDarkModeOn ? .dark : .light)
    }
}

struct user: Codable {
    let joke: String
    let category: String
}

class JokeReader {

    func readJoke(_ joke: String, withVoice voice: String = "en-US", atRate rate: Float = 0.4) {
        let utterance = AVSpeechUtterance(string: joke)
        utterance.voice = AVSpeechSynthesisVoice(language: voice)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rate
        synthesizer.speak(utterance)
    }

    func pauseReading() {
        synthesizer.pauseSpeaking(at: .immediate)
    }

    func continueReading() {
        synthesizer.continueSpeaking()
    }

    func stopReading() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func isSpeaking() -> Bool {
        return synthesizer.isSpeaking
    }

    func availableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
}

#Preview {
    ContentView()
}
