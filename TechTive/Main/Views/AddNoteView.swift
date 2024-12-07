//
//  AddNoteView.swift
//  TechTive
//
//  Created by jiwon jeong on 11/25/24.
//

import SwiftUI


struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var attributedText: NSAttributedString
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var isLoading = false
    @State private var error: String?
    @ObservedObject var viewModel: NotesViewModel
    let isEditing: Bool
    private let originalNote: Note?
    
    init(viewModel: NotesViewModel, note: Note? = nil) {
        self.viewModel = viewModel
        self.isEditing = note != nil
        self.originalNote = note
        
        if let note = note {
            let normalizedText = NSMutableAttributedString(attributedString: note.toAttributedString())
            normalizedText.enumerateAttributes(in: NSRange(location: 0, length: normalizedText.length), options: []) { attributes, range, _ in
                if attributes[.font] == nil {
                    normalizedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: range)
                }
            }
            _attributedText = State(initialValue: normalizedText)
        } else {
            let defaultText = NSMutableAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 17)])
            _attributedText = State(initialValue: defaultText)
        }
    }
   
    private func postNote() async throws {
        let url = URL(string: "https://631c-128-84-124-32.ngrok-free.app/api/posts/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get token from AuthViewModel
        let token = try await authViewModel.getAuthToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Create request body with just the content
        let requestBody: [String: Any] = [
            "content": attributedText.string
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        // Print raw response data immediately after receiving it
        if let responseString = String(data: data, encoding: .utf8) {
            print("📍 DEBUG - Raw Response: \(responseString)")
        }
        
        guard let httpUrlResponse = httpResponse as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("📥 DEBUG - Response status code: \(httpUrlResponse.statusCode)")
        
        // Print parsed JSON for debugging
        do {
            let json = try JSONSerialization.jsonObject(with: data)
            print("📍 DEBUG - Parsed JSON: \(json)")
        } catch {
            print("📍 DEBUG - JSON Parsing Error: \(error)")
        }
        
        guard (200...299).contains(httpUrlResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
        }
        
        do {
            let noteResponse = try decoder.decode(CreateNoteResponse.self, from: data)
            await MainActor.run {
                viewModel.notes.append(noteResponse.post)
            }
        } catch {
            print("📍 DEBUG - Decoding Error: \(error)")
            throw error
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Formatting toolbar
                HStack(spacing: 16) {
                    Button(action: { toggleHeader() }) {
                        Image(systemName: "textformat.size.larger")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    Button(action: { toggleBold() }) {
                        Image(systemName: "bold")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                    
                    Button(action: { toggleItalic() }) {
                        Image(systemName: "italic")
                            .foregroundColor(Color(UIColor.color.orange))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                Divider()
                    .background(Color.orange)
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                FormattedTextView(attributedText: $attributedText, selectedRange: $selectedRange)
                    .background(Color(UIColor.color.lightYellow))
                    .cornerRadius(12)
                    .padding()
            }
            .background(Color(UIColor.color.lightYellow).opacity(0.3))
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(UIColor.color.orange))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        isLoading = true
                        error = nil
                        
                        Task {
                            do {
                                try await postNote()
                                await MainActor.run {
                                    dismiss()
                                }
                            } catch {
                                await MainActor.run {
                                    self.error = "Failed to post note: \(error.localizedDescription)"
                                    isLoading = false
                                }
                            }
                        }
                    }
                    .foregroundColor(Color(UIColor.color.orange))
                    .disabled(isLoading || attributedText.string.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
                }
            }
        }
    }
    
    private func toggleHeader() {
        guard selectedRange.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        
        var isCurrentlyHeader = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyHeader = font.pointSize >= 24
        }
        
        let newFont = isCurrentlyHeader
        ? UIFont.systemFont(ofSize: 17)
        : UIFont.systemFont(ofSize: 24, weight: .bold)
        
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
    
    private func toggleBold() {
        guard selectedRange.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        
        var isCurrentlyBold = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
        }
        
        let newFont = isCurrentlyBold
        ? UIFont.systemFont(ofSize: 17)
        : UIFont.boldSystemFont(ofSize: 17)
        
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
    
    private func toggleItalic() {
        guard selectedRange.length > 0 else { return }
        
        let mutableAttrString = NSMutableAttributedString(attributedString: attributedText)
        
        var isCurrentlyItalic = false
        if let font = attributedText.attributes(at: selectedRange.location, effectiveRange: nil)[.font] as? UIFont {
            isCurrentlyItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        }
        
        let newFont = isCurrentlyItalic
        ? UIFont.systemFont(ofSize: 17)
        : UIFont.italicSystemFont(ofSize: 17)
        
        mutableAttrString.addAttribute(.font, value: newFont, range: selectedRange)
        attributedText = mutableAttrString
    }
}

#Preview {
    AddNoteView(viewModel: NotesViewModel())
        .environmentObject(AuthViewModel())
}
