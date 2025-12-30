import Foundation
import Combine
import WidgetKit
import ActivityKit

import Foundation
import Combine
import WidgetKit
import ActivityKit

@MainActor
class UVViewModel: ObservableObject {
    @Published var locations: [UVLocation] = []
    @Published var allLocationNames: [String] = []
    @Published var lastUpdateTime: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userCity: String? = SelectedCityManager.get()
    
    private var timer: Timer?
    private let service = UVService.shared
    private var isCurrentlyFetching = false
    
    init() {
        startAutoRefresh()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startAutoRefresh() {
        Task {
            await fetchData()
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 60 * 15, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchData()
            }
        }
    }

    func fetchData() async {
        guard !isCurrentlyFetching else { return }
        isCurrentlyFetching = true
        isLoading = true
        
        do {
            let fetchedLocations = try await service.fetchUVData()
            self.allLocationNames = fetchedLocations.map { $0.locationName }.sorted()
            
            if let city = userCity, !city.isEmpty {
                self.locations = fetchedLocations.filter { $0.locationName.caseInsensitiveCompare(city) == .orderedSame }
                
                if let location = self.locations.first {
                    // Add to history
                    let historyEntry = UVData(uv: location.index, timestamp: Date(), locationName: location.locationName)
  
                }
            } else {
                self.locations = fetchedLocations
            }
            
            lastUpdateTime = Date()
        } catch {
            errorMessage = "Failed to fetch UV data: \(error.localizedDescription)"
        }
        
        isLoading = false
        isCurrentlyFetching = false
    }

    func getRelativeTimeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastUpdateTime, relativeTo: Date())
    }
    
    func setUserCity(_ city: String) {
        SelectedCityManager.set(city)
        userCity = city
        WidgetCenter.shared.reloadAllTimelines()
        Task { await fetchData() }
    }
}
