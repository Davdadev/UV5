import SwiftUI

struct WidgetHelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add the UV Index Widget")
                    .font(.title).bold()
                Text("To add the widget to your Home Screen:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Go to the Home Screen and touch and hold an empty area until the apps jiggle.")
                    Text("2. Tap the “+” button in the top-left corner.")
                    Text("3. Search for ‘UV Index’ or find our app in the list.")
                    Text("4. Choose a size and tap Add Widget.")
                }
                .font(.body)
                .padding(.vertical, 8)
                
                Text("Tips")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    Text("• You can place multiple widgets with different sizes.")
                    Text("• Our widget updates periodically; opening the app helps keep data fresh.")
                }
                .font(.body)
                
                Spacer(minLength: 12)
                Text("Note: iOS does not allow apps to automatically add widgets. The steps above ensure you stay in control of your Home Screen.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle("Add Widget")
    }
}

#Preview {
    NavigationStack { WidgetHelpView() }
}
