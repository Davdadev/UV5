import Foundation

class UVService {
    static let shared = UVService()
    private let xmlURL = "https://uvdata.arpansa.gov.au/xml/uvvalues.xml"
    
    private init() {}
    
    func fetchUVData() async throws -> [UVLocation] {
        guard let url = URL(string: xmlURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let locations = try parseXMLData(data)
        return locations
    }
    
    private func parseXMLData(_ data: Data) throws -> [UVLocation] {
        let parser = UVXMLParser()
        return try parser.parse(data: data)
    }
}

// XML Parser aligned to ARPANSA feed structure
class UVXMLParser: NSObject, XMLParserDelegate {
    private var locations: [UVLocation] = []
    private var currentLocationId: String = ""
    private var currentIndex: String = ""
    private var currentTime: String = ""
    private var foundCharacters: String = ""
    private var parseError: Error?
    
    func parse(data: Data) throws -> [UVLocation] {
        locations = []
        parseError = nil
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            return locations
        }
        if let error = parseError ?? parser.parserError { throw error }
        throw NSError(domain: "UVXMLParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown XML parsing error"])
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        foundCharacters = ""
        if elementName == "location" {
            // Reset for a new location
            currentLocationId = attributeDict["id"] ?? ""
            currentIndex = ""
            currentTime = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Accumulate trimmed text
        foundCharacters += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "index":
            currentIndex = foundCharacters
        case "time":
            // Prefer time for display; if needed, we could also read utcdatetime
            currentTime = foundCharacters
        case "location":
            if !currentLocationId.isEmpty {
                let loc = UVLocation(
                    id: currentLocationId.replacingOccurrences(of: " ", with: "_").lowercased(),
                    locationName: currentLocationId,
                    index: Double(currentIndex) ?? 0.0,
                    fullTime: currentTime
                )
                locations.append(loc)
            }
        default:
            break
        }
        foundCharacters = ""
    }
}
