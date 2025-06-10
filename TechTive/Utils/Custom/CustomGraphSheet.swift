import SwiftUI

struct CustomGraphSheet: View {
    let note: Note
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color(Constants.Colors.backgroundColor)
                    .ignoresSafeArea(.all)

                VStack(spacing: 20) {
                    GraphView(note: self.note)
                        .background(Color.clear)

                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Emotion Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    self.isPresented = false
                }
                .foregroundColor(Color(Constants.Colors.orange)))
        }
        .accentColor(Color(Constants.Colors.orange))
    }
}
