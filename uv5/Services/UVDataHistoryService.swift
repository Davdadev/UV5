import Foundation

class UVDataHistoryService {
    static let shared = UVDataHistoryService()
    
    private let fileName = "uv_data_history.json"
    private var fileURL: URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(fileName)
    }
    
    private init() {}
    
    func add(uvData: UVData) {
        DispatchQueue.global(qos: .background).async {
            var history = self.getHistory()
            history.append(uvData)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            do {
                let data = try encoder.encode(history)
                try data.write(to: self.fileURL)
            } catch {
                print("Error saving UV data history: \(error)")
            }
        }
    }
    
    func getHistory() -> [UVData] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let history = try decoder.decode([UVData].self, from: data)
            return history
        } catch {
            // If the file doesn't exist or there's a decoding error, return an empty array.
            return []
        }
    }
    
    func getTodaysHistory() -> [UVData] {
        let history = getHistory()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return history.filter {
            calendar.isDate($0.timestamp, inSameDayAs: today)
        }
    }
}
