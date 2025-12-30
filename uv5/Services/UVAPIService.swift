import Foundation

class UVAPIService {
    static let shared = UVAPIService()
    private let apiKey = "YOUR_API_KEY" // Replace with your OpenUV API key
    private let baseURL = "https://api.openuv.io/api/v1/uv"
    
    private init() {}
    
    func fetchUVData(lat: Double, lng: Double) async throws -> UVData {
        guard apiKey != "YOUR_API_KEY" else {
            throw NSError(domain: "UVAPIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Please replace YOUR_API_KEY with your OpenUV API key."])
        }
        
        guard let url = URL(string: "\(baseURL)?lat=\(lat)&lng=\(lng)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-access-token")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try decoder.decode(UVDataResponse.self, from: data)
        
        let result = response.result
        let dateFormatter = ISO8601DateFormatter()
        
        let uvTime = dateFormatter.date(from: result.uvTime) ?? Date()
        let uvMaxTime = dateFormatter.date(from: result.uvMaxTime) ?? Date()
        
        let uvData = UVData(
            uv: result.uv,
            timestamp: Date(),
            locationName: nil,
            uvTime: uvTime,
            uvMax: result.uvMax,
            uvMaxTime: uvMaxTime,
            safeExposure: result.safeExposure
        )
        
        // Save to history

        
        return uvData
    }
}
