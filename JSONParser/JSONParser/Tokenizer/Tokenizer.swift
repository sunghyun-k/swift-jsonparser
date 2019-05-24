import Foundation

extension String {
    func checkingAndTrimmingCharacters(begin: Character, end: Character) -> String? {
        guard self.first == begin, self.last == end else {
            return nil
        }
        var result = self
        result.removeFirst()
        result.removeLast()
        return result
    }
}

struct Tokenizer {
    
    enum TokenizingError: Error {
        case cannotDetectBeginOrEndOfArray
        case cannotDetectBeginOrEndOfObject
        case invalidNestedStructure
        case invalidArrayGrammar
        case invalidObjectGrammar
        case bufferIsEmpty
        case cannotFindNameSeparator
        case objectKeyShouldBeOneAndOnly
    }
    
    static func arrayTokenize(input: String) throws -> [String] {
        guard let input = input.checkingAndTrimmingCharacters(begin: Token.beginArray, end: Token.endArray) else {
            throw TokenizingError.cannotDetectBeginOrEndOfArray
        }
        guard FormatValidator.validateArrayFormat(input) else {
            throw TokenizingError.invalidArrayGrammar
        }
        return try separateValues(input: input)
    }
    
    static func objectTokenize(input: String) throws -> [String: String] {
        guard let input = input.checkingAndTrimmingCharacters(begin: Token.beginObject, end: Token.endObject) else {
            throw TokenizingError.cannotDetectBeginOrEndOfObject
        }
        guard FormatValidator.validateObjectFormat(input) else {
            throw TokenizingError.invalidObjectGrammar
        }
        
        let separatedInput = try separateValues(input: input)
        var result = [String: String]()
        for value in separatedInput {
            let keyAndValue = try splitKeyAndValue(keyAndValue: value)
            guard result[keyAndValue.key] == nil else {
                throw TokenizingError.objectKeyShouldBeOneAndOnly
            }
            result[keyAndValue.key] = keyAndValue.value
        }
        return result
    }
    
    private static func splitKeyAndValue(keyAndValue: String) throws -> (key: String, value: String) {
        var value = keyAndValue
        var key = ""
        var isParsingKey = false
        for character in keyAndValue {
            if character == Token.quotationMark { isParsingKey.toggle() }
            if !isParsingKey, character == Token.nameSeparator {
                break
            }
            key.append(value.removeFirst())
        }
        guard let nameSeparatorIndex = value.firstIndex(of: Token.nameSeparator) else {
            throw TokenizingError.cannotFindNameSeparator
        }
        value.removeSubrange(value.startIndex...nameSeparatorIndex)
        
        return (key, value.trimmingCharacters(in: Token.whitespace))
    }
    
    private static func separateValues(input: String) throws -> [String] {
        
        let input = input.trimmingCharacters(in: Token.whitespace)
        
        if input == "" { return [] }
        
        var result = [String]()
        var buffer = ""
        
        var isParsingString = false
        var nestedArrayCount: UInt = 0
        var nestedObjectCount: UInt = 0
        
        func moveBufferToResult() throws {
            guard !buffer.isEmpty else {
                throw TokenizingError.bufferIsEmpty
            }
            let whitespaceTrimmedString = buffer.trimmingCharacters(in: Token.whitespace)
            
            result.append(whitespaceTrimmedString)
            buffer.removeAll()
        }
        
        func parse(character: Character) throws {
            switch character {
            case Token.endArray:
                guard nestedArrayCount > 0 else {
                    throw TokenizingError.invalidNestedStructure
                }
                nestedArrayCount -= 1
            case Token.beginArray:
                nestedArrayCount += 1
            case Token.endObject:
                guard nestedObjectCount > 0 else {
                    throw TokenizingError.invalidNestedStructure
                }
                nestedObjectCount -= 1
            case Token.beginObject:
                nestedObjectCount += 1
            case Token.valueSeparator:
                guard nestedArrayCount == 0, nestedObjectCount == 0 else { break }
                try moveBufferToResult()
                return
            default:
                break
            }
            buffer.append(character)
        }
        
        for character in input {
            if character == Token.quotationMark {
                isParsingString.toggle()
                buffer.append(character)
            } else if !isParsingString {
                try parse(character: character)
            }
            
        }
        try moveBufferToResult()
        return result
    }
    
    
    
}




