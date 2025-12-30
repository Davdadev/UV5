import SwiftUI

struct LocationRowView: View {
    let location: UVLocation
    
    var body: some View {
        VStack(spacing: 12) {
            // Top-of-page city header
            
            
            // Large, centered UV badge
ZStack {
                Circle()
                    .fill(UVIndexHelper.colorForIndex(location.index))
                    .frame(width: 96, height: 96)
                Text(String(format: "%.1f", location.index))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct LocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRowView(
            location: UVLocation(
                id: "1",
                locationName: "Sydney",
                index: 7.5,
                fullTime: "2024-01-01 12:00:00"
            )
        )
        .padding()
    }
}
