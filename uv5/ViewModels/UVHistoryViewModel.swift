import Foundation
import Combine

@MainActor
class UVHistoryViewModel: ObservableObject {
    @Published var todaysHistory: [UVData] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(city: String?) {
        loadHistory(for: city)
    }
    
    func loadHistory(for city: String?) {
        let fullHistory = UVDataHistoryService.shared.getTodaysHistory()
        if let city = city, !city.isEmpty {
            self.todaysHistory = fullHistory.filter { $0.locationName?.caseInsensitiveCompare(city) == .orderedSame }
        } else {
            self.todaysHistory = fullHistory
        }
    }
}
