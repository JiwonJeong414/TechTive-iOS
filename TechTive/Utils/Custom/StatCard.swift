import SwiftUI

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(self.title)
                .font(Constants.Fonts.poppinsRegular14)
                .foregroundColor(Color(Constants.Colors.black))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .lineLimit(2)

            Text(self.value)
                .font(Constants.Fonts.poppinsSemiBold20)
                .foregroundColor(Color(Constants.Colors.profileOrange))
        }
        .frame(width: 110, height: 110)
        .background(Color(Constants.Colors.lightYellow).opacity(0.4))
        .cornerRadius(12)
    }
}
