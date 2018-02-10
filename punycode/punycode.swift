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
public func decodePunycode(_ punycode: String) -> String? {
	var n = initialN
	var i = 0
	var bias = initialBias
	var output: [Character] = []
	var inputPosition = punycode.startIndex

	if let delimeterPosition = punycode.lastIndex(of: delimeter) {
		output.append(contentsOf: punycode[..<delimeterPosition])
		guard delimeterPosition < punycode.endIndex else {
			return String(output)
		}
		inputPosition = punycode.index(after: delimeterPosition)
	} else {
		return punycode // The original string is not encoded
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
public func encodePunycode(_ input: String) -> String? {
	var n = initialN
	var delta = 0
	var bias = initialBias
	var output = ""
	var delimeterEncountered = false

	for scalar in input.unicodeScalars {
		if scalar.isASCII {
			let char = Character(scalar)
			output.append(char)
			if char == delimeter {
				delimeterEncountered = true
			}
		} else if !scalar.isValid {
			return nil
		}
	}
	var h = output.count
	let b = h
	if output.count == input.count && !delimeterEncountered {
		return output	// The original string is ASCII
	}
	output.append(delimeter)

	while h < input.unicodeScalars.count {
		var minimumCodepoint = 0x10FFFF
		for scalar in input.unicodeScalars {
			if scalar.value < minimumCodepoint && scalar.value >= n {
				minimumCodepoint = Int(scalar.value)
			}
		}
		delta += (minimumCodepoint - n) * (h + 1)
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
					if let character = punycodeValue(for: t + ((q - t) % (base - t))) {
						output.append(character)
					} else {
						return nil
					}
					q = (q - t) / (base - t)
					k += base
				}
				if let character = punycodeValue(for: q) {
					output.append(character)
				} else {
					return nil
				}
				bias = adaptBias(delta, h + 1, h == b)
				delta = 0
				h += 1
			}
		}
		delta += 1
		n += 1
	}

	return output
}

extension String {

	/// Returns a copy of string in punycode encoding (RFC 3492)
	///
	/// - Returns: Punycode encoded string or nil if the string can't be encoded
	public func punycodeEncoded() -> String? {
		return encodePunycode(self)
	}


	/// Returns a copy of string decoded from punycode representation (RFC 3492)
	///
	/// - Returns: Original string or nil if the string doesn't contain correct encoding
	public func punycodeDecoded() -> String? {
		return decodePunycode(self)
	}
}

// Helpers
extension String {

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

