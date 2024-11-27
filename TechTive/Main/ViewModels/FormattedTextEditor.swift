//
//  FormattedTextEditor.swift
//  TechTive
//
//  Created by jiwon jeong on 11/27/24.
//

import SwiftUI

struct FormattedTextEditor: View {
    @Binding var text: String
    @State private var formattedText: AttributedString = AttributedString("")
    
    var body: some View {
        TextEditor(text: $text)
            .onChange(of: text) { oldValue, newValue in
                formattedText = parseAndFormatText(newValue)
            }
            .font(.body)
    }
    
    private func parseAndFormatText(_ input: String) -> AttributedString {
        var result = AttributedString()
        var currentText = ""
        var isInCommand = false
        var commandType = ""
        
        // Helper function to add formatted text
        func addFormattedText(_ text: String, command: String = "") {
            var attributes: AttributeContainer = AttributeContainer()
            
            switch command {
            case "h1":
                attributes.font = .system(.title).bold()
            case "h2":
                attributes.font = .system(.title2).bold()
            case "bullet":
                currentText = "• " + text
                attributes.font = .body
            case "code":
                attributes.font = .system(.body, design: .monospaced)
                attributes.backgroundColor = .gray.opacity(0.2)
            default:
                attributes.font = .body
            }
            
            result.append(AttributedString(currentText, attributes: attributes))
            if !command.isEmpty && result.characters.last != "\n" {
                result.append(AttributedString("\n"))
            }
        }
        
        var tempCommand = ""
        
        for char in input {
            if isInCommand {
                if char == "{" {
                    commandType = tempCommand
                    tempCommand = ""
                    continue
                }
                if char == "}" {
                    addFormattedText(currentText, command: commandType)
                    isInCommand = false
                    currentText = ""
                    tempCommand = ""
                    continue
                }
                if commandType.isEmpty {
                    tempCommand.append(char)
                } else {
                    currentText.append(char)
                }
            } else {
                if char == "h" || char == "b" || char == "c" {
                    if !currentText.isEmpty {
                        addFormattedText(currentText)
                        currentText = ""
                    }
                    isInCommand = true
                    tempCommand.append(char)
                } else {
                    currentText.append(char)
                }
            }
        }
        
        if !currentText.isEmpty {
            addFormattedText(currentText)
        }
        
        return result
    }
}
