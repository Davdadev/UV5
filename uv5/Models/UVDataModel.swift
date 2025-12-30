import Foundation

struct UVDataResponse: Codable {
    let result: ResultData
}

struct ResultData: Codable {
    let uv: Double
    let uvTime: String
    let uvMax: Double
    let uvMaxTime: String
    let safeExposure: SafeExposure
    
    enum CodingKeys: String, CodingKey {
        case uv
        case uvTime = "uv_time"
        case uvMax = "uv_max"
        case uvMaxTime = "uv_max_time"
        case safeExposure = "safe_exposure_time"
    }
}

struct SafeExposure: Codable {
    let st1, st2, st3, st4, st5, st6: Int?
}

struct UVData: Codable {
    let uv: Double
    let timestamp: Date
    let locationName: String?
    
    // These fields are optional as they are not available from the XML feed
    let uvTime: Date?
    let uvMax: Double?
    let uvMaxTime: Date?
    let safeExposure: SafeExposure?
    
    init(uv: Double, timestamp: Date, locationName: String?, uvTime: Date? = nil, uvMax: Double? = nil, uvMaxTime: Date? = nil, safeExposure: SafeExposure? = nil) {
        self.uv = uv
        self.timestamp = timestamp
        self.locationName = locationName
        self.uvTime = uvTime
        self.uvMax = uvMax
        self.uvMaxTime = uvMaxTime
        self.safeExposure = safeExposure
    }
}
