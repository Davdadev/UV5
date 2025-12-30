import SwiftUI

struct ContentView: View {
    @StateObject private var uvViewModel = UVViewModel()
    @State private var isShowingCitySelection = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                if let userCity = uvViewModel.userCity, !userCity.isEmpty {
                    Text("UV Index for \(userCity)")
                        .font(.largeTitle)
                        .padding(.top, -24)
                        .padding(.bottom, 4)
                    
                    if uvViewModel.isLoading {
                        ProgressView()
                    } else if let location = uvViewModel.locations.first {
                        VStack(spacing: 1) {
                            Text("\(location.index, specifier: "%.1f")")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(UVIndexHelper.colorForIndex(location.index))
                            Text(UVIndexHelper.descriptionForIndex(location.index))
                                .font(.title)
                            Text("Last updated: \(uvViewModel.getRelativeTimeString())")
                                .font(.caption)
                        }
                    } else {
                        Text("No data available for \(userCity).")
                    }
                    
                    UVHistoryView(city: userCity) // Add the history view
                    
                } else {
                    Text("Please select a city")
                        .font(.headline)
                }
            }
            .navigationTitle("UV Index")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $isShowingCitySelection) {
                CitySelectionView(cities: uvViewModel.allLocationNames) { city in
                    uvViewModel.setUserCity(city)
                    isShowingCitySelection = false
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(cities: uvViewModel.allLocationNames, currentCity: uvViewModel.userCity) { city in
                    uvViewModel.setUserCity(city)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
