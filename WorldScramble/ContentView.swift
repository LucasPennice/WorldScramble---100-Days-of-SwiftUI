//
//  ContentView.swift
//  WorldScramble
//
//  Created by Lucas Pennice on 09/02/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords : [String] = []
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var error : (String, String) = ("","")
    @State private var showError = false
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section{
                    ForEach(usedWords, id: \.self){word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)}
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(error.0, isPresented: $showError){} message: {Text(error.1)}
            .toolbar{Button("Restart", action: startGame)}
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return wordError(title: "Can't use an empty word", message: "...")}
        
        guard isOriginal(word: answer) else {return wordError(title: "Word in use", message: "Be more original")}
        guard isPossible(word: answer) else {return wordError(title: "Word not possible", message: "...")}
        guard isReal(word: answer) else {return wordError(title: "Word not recognized", message: "...")}
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        
        newWord = ""
    }
    
    func startGame(){
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {return gameStartingError()}
        
        guard let startWords = try? String(contentsOf: startWordsURL) else {return gameStartingError()}
        
        let allWords = startWords.components(separatedBy: "\n")
        
        guard let newRootWord = allWords.randomElement() else {return gameStartingError()}
        
        rootWord = newRootWord
    }
    
    func isOriginal(word:String) -> Bool {!usedWords.contains(word)}
    
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            guard let pos = tempWord.firstIndex(of: letter) else {return false}
            
            tempWord.remove(at: pos)
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func wordError(title:String, message:String){
        error = (title, message)
        showError = true
    }
}

func gameStartingError(){fatalError("Could not load start.txt from bundle")}

#Preview {
    ContentView()
}
