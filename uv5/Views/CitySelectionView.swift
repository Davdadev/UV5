import SwiftUI

struct CitySelectionView: View {
    let cities: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        NavigationView {
            List(cities, id: \.self) { city in
                Button(action: { onSelect(city) }) {
                    HStack {
                        Text(city)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Choose City")
        }
    }
}

#Preview {
    CitySelectionView(cities: ["Sydney", "Melbourne", "Brisbane"], onSelect: { _ in })
}
