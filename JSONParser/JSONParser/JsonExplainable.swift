import Foundation

protocol JsonExplainable {
    var typeDescription: String { get }
    var countDescription: String { get }
}

protocol JsonSingleValueExplainable: JsonExplainable { }

extension JsonSingleValueExplainable {
    var countDescription: String {
        return "총 1개의 데이터 중에 \(self.typeDescription) 1개가 포함되어 있습니다."
    }
}

extension String: JsonSingleValueExplainable {
    var typeDescription: String { return "문자열" }
}

typealias Number = Double
extension Number: JsonSingleValueExplainable {
    var typeDescription: String { return "숫자" }
}

extension Bool: JsonSingleValueExplainable {
    var typeDescription: String { return "부울" }
}

extension Array: JsonExplainable where Element == JsonExplainable {
    
    var typeDescription: String { return "배열" }
    
    var countDescription: String {
        guard !self.isEmpty else {
            return "빈 배열입니다."
        }
        var counts = [String: Int]()
        for item in self {
            counts[item.typeDescription] = (counts[item.typeDescription] ?? 0) + 1
        }
        
        let countsString = counts.map { "\($0.key) \($0.value)개" }
        return "이 배열에는 총 \(self.count)개의 데이터 중에 \(countsString.joined(separator: ", "))가 포함되어 있습니다."
    }
    
}

extension Dictionary: JsonExplainable where Key == String ,Value == JsonExplainable {
    
    var typeDescription: String { return "오브젝트" }
    
    var countDescription: String {
        guard !self.isEmpty else {
            return "빈 오브젝트입니다."
        }
        var counts = [String: Int]()
        for (_, value) in self {
            counts[value.typeDescription] = (counts[value.typeDescription] ?? 0) + 1
        }
        
        let countsString = counts.map { "\($0.key) \($0.value)개" }
        return "이 오브젝트에는 총 \(self.count)개의 데이터 중에 \(countsString.joined(separator: ", "))가 포함되어 있습니다."
    }
    
}