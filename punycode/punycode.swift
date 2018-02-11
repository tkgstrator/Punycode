// Punycode RFC 3492
// See https://www.ietf.org/rfc/rfc3492.txt for standard details
//
//  Created by Viktor Chernikov on 10/02/2018.
//  Copyright © 2018 Viktor Chernikov. All rights reserved.
// 	Swift 4

import Foundation

fileprivate let base = 36
fileprivate let tMin = 1
fileprivate let tMax = 26
fileprivate let skew = 38
fileprivate let damp = 700
fileprivate let initialBias = 72
fileprivate let initialN = 128

// RFC 3492 specific
fileprivate let delimeter: Character = "-"
fileprivate let lowercase: ClosedRange<Character> = "a"..."z"
fileprivate let digits: ClosedRange<Character> = "0"..."9"
fileprivate let lettersBase = Character("a").unicodeScalars.first!.value
fileprivate let digitsBase = Character("0").unicodeScalars.first!.value

// IDNA
fileprivate let ace = "xn--"

fileprivate func adaptBias(_ delta: Int, _ numberOfPoints: Int, _ firstTime: Bool) -> Int {
	var delta = delta
	if firstTime {
		delta /= damp
	} else {
		delta /= 2
	}
	delta += delta / numberOfPoints
	var k = 0
	while delta > ((base - tMin) * tMax) / 2 {
		delta /= base - tMin
		k += base
	}
	return k + ((base - tMin + 1) * delta) / (delta + skew)
}

/// Maps a punycode character to index
fileprivate func punycodeIndex(for character: Character) -> Int? {
	if lowercase.contains(character) {
		return Int(character.unicodeScalars.first!.value - lettersBase)
	} else if digits.contains(character) {
		return Int(character.unicodeScalars.first!.value - digitsBase) + 26 // count of lowercase letters range
	} else {
		return nil
	}
}

/// Maps an index to corresponding punycode character
fileprivate func punycodeValue(for digit: Int) -> Character? {
	guard digit < base else { return nil }
	if digit < 26 {
		return Character(UnicodeScalar(lettersBase.advanced(by: digit))!)
	} else {
		return Character(UnicodeScalar(digitsBase.advanced(by: digit - 26))!)
	}
}

/// Decodes punycode encoded string to original representation
///
/// - Parameter punycode: Punycode encoding (RFC 3492)
/// - Returns: Decoded string or nil if the input cannot be decoded
fileprivate func decodePunycode(_ punycode: Substring) -> String? {
	var n = initialN
	var i = 0
	var bias = initialBias
	var output: [Character] = []
	var inputPosition = punycode.startIndex

	let delimeterPosition = punycode.lastIndex(of: delimeter) ?? punycode.startIndex;
	if delimeterPosition > punycode.startIndex {
		output.append(contentsOf: punycode[..<delimeterPosition])
		inputPosition = punycode.index(after: delimeterPosition)
	}
	var punycodeInput = punycode[inputPosition..<punycode.endIndex]
	while !punycodeInput.isEmpty {
		let oldI = i
		var w = 1
		var k = base
		while true {
			let character = punycodeInput.removeFirst()
			guard let digit = punycodeIndex(for: character) else {
				return nil    // Failing on badly formatted punycode
			}

			i += digit * w
			let t = k <= bias ? tMin : (k >= bias + tMax ? tMax : k - bias)
			if digit < t {
				break
			}
			w *= base - t
			k += base
		}
		bias = adaptBias(i - oldI, output.count + 1, oldI == 0)
		n += i / (output.count + 1)
		i %= (output.count + 1)
		guard n >= 0x80, let scalar = UnicodeScalar(n) else {
			return nil
		}
		output.insert(Character(scalar), at: i)
		i += 1
	}

	return String(output)
}

/// Encodes string to punycode (RFC 3492)
///
/// - Parameter input: Input string
/// - Returns: Punycode encoded string
fileprivate func encodePunycode(_ input: Substring) -> String? {
	var n = initialN
	var delta = 0
	var bias = initialBias
	var output = ""

	for scalar in input.unicodeScalars {
		if scalar.isASCII {
			let char = Character(scalar)
			output.append(char)
		} else if !scalar.isValid {
			return nil // Encountered a scalar out of acceptible range
		}
	}
	var handled = output.count
	let basic = handled
	if basic > 0 {
		output.append(delimeter)
	}

	while handled < input.unicodeScalars.count {
		var minimumCodepoint = 0x10FFFF
		for scalar in input.unicodeScalars {
			if scalar.value < minimumCodepoint && scalar.value >= n {
				minimumCodepoint = Int(scalar.value)
			}
		}
		delta += (minimumCodepoint - n) * (handled + 1)
		n = minimumCodepoint
		for scalar in input.unicodeScalars {
			if scalar.value < n {
				delta += 1
			} else if scalar.value == n {
				var q = delta
				var k = base
				while true {
					let t = k <= bias ? tMin : (k >= bias + tMax ? tMax : k - bias)
					if q < t {
						break
					}
					guard let character = punycodeValue(for: t + ((q - t) % (base - t))) else { return nil }
					output.append(character)
					q = (q - t) / (base - t)
					k += base
				}
				guard let character = punycodeValue(for: q) else { return nil }
				output.append(character)
				bias = adaptBias(delta, handled + 1, handled == basic)
				delta = 0
				handled += 1
			}
		}
		delta += 1
		n += 1
	}

	return output
}

// For calling site convenience everything is implemented over Substring and String API is wrapped around it
public extension Substring {
	/// Returns new string in punycode encoding (RFC 3492)
	///
	/// - Returns: Punycode encoded string or nil if the string can't be encoded
	func punycodeEncoded() -> String? {
		return encodePunycode(self)
	}


	/// Returns new string decoded from punycode representation (RFC 3492)
	///
	/// - Returns: Original string or nil if the string doesn't contain correct encoding
	func punycodeDecoded() -> String? {
		return decodePunycode(self)
	}

	/// Returns new string containing IDNA-encoded hostname
	///
	/// - Returns: IDNA encoded hostname or nil if the string can't be encoded
	func idnaEncoded() -> String? {
		let parts = self.split(separator: ".")
		var output = ""
		for part in parts {
			if output.count > 0 {
				output.append(".")
			}
			if part.rangeOfCharacter(from: CharacterSet.urlHostAllowed.inverted) != nil {
				guard let encoded = part.lowercased().punycodeEncoded() else { return nil }
				output += ace + encoded
			} else {
				output += part
			}
		}
		return output
	}

	/// Returns new string containing hostname decoded from IDNA representation
	///
	/// - Returns: Original hostname or nil if the string doesn't contain correct encoding
	func idnaDecoded() -> String? {
		let parts = self.split(separator: ".")
		var output = ""
		for part in parts {
			if output.count > 0 {
				output.append(".")
			}
			if part.hasPrefix(ace) {
				guard let decoded = part.dropFirst(ace.count).punycodeDecoded() else { return nil }
				output += decoded
			} else {
				output += part
			}
		}
		return output
	}
}

public extension String {

	/// Returns new string in punycode encoding (RFC 3492)
	///
	/// - Returns: Punycode encoded string or nil if the string can't be encoded
	func punycodeEncoded() -> String? {
		return encodePunycode(self[..<self.endIndex])
	}


	/// Returns new string decoded from punycode representation (RFC 3492)
	///
	/// - Returns: Original string or nil if the string doesn't contain correct encoding
	func punycodeDecoded() -> String? {
		return decodePunycode(self[..<self.endIndex])
	}

	/// Returns new string containing IDNA-encoded hostname
	///
	/// - Returns: IDNA encoded hostname or nil if the string can't be encoded
	func idnaEncoded() -> String? {
		return self[..<self.endIndex].idnaEncoded()
	}

	/// Returns new string containing hostname decoded from IDNA representation
	///
	/// - Returns: Original hostname or nil if the string doesn't contain correct encoding
	func idnaDecoded() -> String? {
		return self[..<self.endIndex].idnaDecoded()
	}
}

// Helpers
extension Substring {

	fileprivate func lastIndex(of element: Character) -> String.Index? {
		var position = endIndex
		while position > startIndex {
			position = self.index(before: position)
			if self[position] == element {
				return position
			}
		}
		return nil
	}
}

extension UnicodeScalar {

	fileprivate var isValid: Bool {
		return value < 0xD880 || (value >= 0xE000 && value <= 0x1FFFFF)
	}
}

