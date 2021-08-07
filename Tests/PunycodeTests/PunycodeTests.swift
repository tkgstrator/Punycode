import XCTest
@testable import Punycode

final class PunycodeTests: XCTestCase {
    let egyptian =     "\u{0644}\u{064A}\u{0647}\u{0645}\u{0627}\u{0628}\u{062A}\u{0643}\u{0644}\u{0645}\u{0648}\u{0634}\u{0639}\u{0631}\u{0628}\u{064A}\u{061F}"
    let chineseSimplified = "\u{4ED6}\u{4EEC}\u{4E3A}\u{4EC0}\u{4E48}\u{4E0D}\u{8BF4}\u{4E2D}\u{6587}"
    let chineseTraditional = "\u{4ED6}\u{5011}\u{7232}\u{4EC0}\u{9EBD}\u{4E0D}\u{8AAA}\u{4E2D}\u{6587}"
    let czech = "\u{0050}\u{0072}\u{006F}\u{010D}\u{0070}\u{0072}\u{006F}\u{0073}\u{0074}\u{011B}\u{006E}\u{0065}\u{006D}\u{006C}\u{0075}\u{0076}\u{00ED}\u{010D}\u{0065}\u{0073}\u{006B}\u{0079}"
    let hebrew = "\u{05DC}\u{05DE}\u{05D4}\u{05D4}\u{05DD}\u{05E4}\u{05E9}\u{05D5}\u{05D8}\u{05DC}\u{05D0}\u{05DE}\u{05D3}\u{05D1}\u{05E8}\u{05D9}\u{05DD}\u{05E2}\u{05D1}\u{05E8}\u{05D9}\u{05EA}"
    let hindi = "\u{092F}\u{0939}\u{0932}\u{094B}\u{0917}\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}\u{0915}\u{094D}\u{092F}\u{094B}\u{0902}\u{0928}\u{0939}\u{0940}\u{0902}\u{092C}\u{094B}\u{0932}\u{0938}\u{0915}\u{0924}\u{0947}\u{0939}\u{0948}\u{0902}"
    let japanese = "\u{306A}\u{305C}\u{307F}\u{3093}\u{306A}\u{65E5}\u{672C}\u{8A9E}\u{3092}\u{8A71}\u{3057}\u{3066}\u{304F}\u{308C}\u{306A}\u{3044}\u{306E}\u{304B}"
    let korean = "\u{C138}\u{ACC4}\u{C758}\u{BAA8}\u{B4E0}\u{C0AC}\u{B78C}\u{B4E4}\u{C774}\u{D55C}\u{AD6D}\u{C5B4}\u{B97C}\u{C774}\u{D574}\u{D55C}\u{B2E4}\u{BA74}\u{C5BC}\u{B9C8}\u{B098}\u{C88B}\u{C744}\u{AE4C}"
    let russian = "\u{043F}\u{043E}\u{0447}\u{0435}\u{043C}\u{0443}\u{0436}\u{0435}\u{043E}\u{043D}\u{0438}\u{043D}\u{0435}\u{0433}\u{043E}\u{0432}\u{043E}\u{0440}\u{044F}\u{0442}\u{043F}\u{043E}\u{0440}\u{0443}\u{0441}\u{0441}\u{043A}\u{0438}"
    let spanish = "\u{0050}\u{006F}\u{0072}\u{0071}\u{0075}\u{00E9}\u{006E}\u{006F}\u{0070}\u{0075}\u{0065}\u{0064}\u{0065}\u{006E}\u{0073}\u{0069}\u{006D}\u{0070}\u{006C}\u{0065}\u{006D}\u{0065}\u{006E}\u{0074}\u{0065}\u{0068}\u{0061}\u{0062}\u{006C}\u{0061}\u{0072}\u{0065}\u{006E}\u{0045}\u{0073}\u{0070}\u{0061}\u{00F1}\u{006F}\u{006C}"
    let vietnamese = "\u{0054}\u{1EA1}\u{0069}\u{0073}\u{0061}\u{006F}\u{0068}\u{1ECD}\u{006B}\u{0068}\u{00F4}\u{006E}\u{0067}\u{0074}\u{0068}\u{1EC3}\u{0063}\u{0068}\u{1EC9}\u{006E}\u{00F3}\u{0069}\u{0074}\u{0069}\u{1EBF}\u{006E}\u{0067}\u{0056}\u{0069}\u{1EC7}\u{0074}"

    let jBlockL = "\u{0033}\u{5E74}\u{0042}\u{7D44}\u{91D1}\u{516B}\u{5148}\u{751F}"
    let jBlockM = "\u{5B89}\u{5BA4}\u{5948}\u{7F8E}\u{6075}\u{002D}\u{0077}\u{0069}\u{0074}\u{0068}\u{002D}\u{0053}\u{0055}\u{0050}\u{0045}\u{0052}\u{002D}\u{004D}\u{004F}\u{004E}\u{004B}\u{0045}\u{0059}\u{0053}"
    let jBlockN = "\u{0048}\u{0065}\u{006C}\u{006C}\u{006F}\u{002D}\u{0041}\u{006E}\u{006F}\u{0074}\u{0068}\u{0065}\u{0072}\u{002D}\u{0057}\u{0061}\u{0079}\u{002D}\u{305D}\u{308C}\u{305E}\u{308C}\u{306E}\u{5834}\u{6240}"
    let jBlockO = "\u{3072}\u{3068}\u{3064}\u{5C4B}\u{6839}\u{306E}\u{4E0B}\u{0032}"
    let jBlockP = "\u{004D}\u{0061}\u{006A}\u{0069}\u{3067}\u{004B}\u{006F}\u{0069}\u{3059}\u{308B}\u{0035}\u{79D2}\u{524D}"
    let jBlockQ = "\u{30D1}\u{30D5}\u{30A3}\u{30FC}\u{0064}\u{0065}\u{30EB}\u{30F3}\u{30D0}"
    let jBlockR = "\u{305D}\u{306E}\u{30B9}\u{30D4}\u{30FC}\u{30C9}\u{3067}"

    let plain = "\u{002D}\u{003E}\u{0020}\u{0024}\u{0031}\u{002E}\u{0030}\u{0030}\u{0020}\u{003C}\u{002D}"
    let multiscalar = "🇨🇦"
    let idna = "погода-в-египте.рф.com"

    let egyptianCode = "egbpdaj6bu4bxfgehfvwxn"
    let chineseSimplifiedCode = "ihqwcrb4cv8a8dqg056pqjye"
    let chineseTraditionalCode = "ihqwctvzc91f659drss3x8bo0yb"
    let czechCode = "Proprostnemluvesky-uyb24dma41a"
    let hebrewCode = "4dbcagdahymbxekheh6e0a7fei0b"
    let hindiCode = "i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd"
    let japaneseCode = "n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa"
    let koreanCode = "989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c"
    let russianCode = "b1abfaaepdrnnbgefbadotcwatmq2g4l"
    let spanishCode = "PorqunopuedensimplementehablarenEspaol-fmd56a"
    let vietnameseCode = "TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g"

    let jBlockLCode = "3B-ww4c5e180e575a65lsy2b"
    let jBlockMCode = "-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n"
    let jBlockNCode = "Hello-Another-Way--fc4qua05auwb3674vfr0b"
    let jBlockOCode = "2-u9tlzr9756bt3uc0v"
    let jBlockPCode = "MajiKoi5-783gue6qz075azm5e"
    let jBlockQCode = "de-jg4avhby1noc0d"
    let jBlockRCode = "d9juau41awczczp"

    let plainCode = "-> $1.00 <--"
    let multiscalarCode = "e77hd"

    let idnaCode = "xn-----6kcjcecmb3a1dbkl9b.xn--p1ai.com"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEncodingCorrectness() {
        XCTAssert(egyptian.punycodeEncoded() == egyptianCode)
        XCTAssert(chineseSimplified.punycodeEncoded() == chineseSimplifiedCode)
        XCTAssert(chineseTraditional.punycodeEncoded() == chineseTraditionalCode)
        XCTAssert(czech.punycodeEncoded() == czechCode)
        XCTAssert(hebrew.punycodeEncoded() == hebrewCode)
        XCTAssert(hindi.punycodeEncoded() == hindiCode)
        XCTAssert(japanese.punycodeEncoded() == japaneseCode)
        XCTAssert(korean.punycodeEncoded() == koreanCode)
        XCTAssert(russian.punycodeEncoded() == russianCode)
        XCTAssert(spanish.punycodeEncoded() == spanishCode)
        XCTAssert(vietnamese.punycodeEncoded() == vietnameseCode)

        XCTAssert(jBlockL.punycodeEncoded() == jBlockLCode)
        XCTAssert(jBlockM.punycodeEncoded() == jBlockMCode)
        XCTAssert(jBlockN.punycodeEncoded() == jBlockNCode)
        XCTAssert(jBlockO.punycodeEncoded() == jBlockOCode)
        XCTAssert(jBlockP.punycodeEncoded() == jBlockPCode)
        XCTAssert(jBlockQ.punycodeEncoded() == jBlockQCode)
        XCTAssert(jBlockR.punycodeEncoded() == jBlockRCode)

        XCTAssert(multiscalar.punycodeEncoded() == multiscalarCode)
        XCTAssert(plain.punycodeEncoded() == plainCode)

        XCTAssert(idna.idnaEncoded() == idnaCode)
    }

    func testDecodingCorrectness() {
        XCTAssert(egyptianCode.punycodeDecoded() == egyptian)
        XCTAssert(chineseSimplifiedCode.punycodeDecoded() == chineseSimplified)
        XCTAssert(chineseTraditionalCode.punycodeDecoded() == chineseTraditional)
        XCTAssert(czechCode.punycodeDecoded() == czech)
        XCTAssert(hebrewCode.punycodeDecoded() == hebrew)
        XCTAssert(hindiCode.punycodeDecoded() == hindi)
        XCTAssert(japaneseCode.punycodeDecoded() == japanese)
        XCTAssert(koreanCode.punycodeDecoded() == korean)
        XCTAssert(russianCode.punycodeDecoded() == russian)
        XCTAssert(spanishCode.punycodeDecoded() == spanish)
        XCTAssert(vietnameseCode.punycodeDecoded() == vietnamese)

        XCTAssert(jBlockLCode.punycodeDecoded() == jBlockL)
        XCTAssert(jBlockMCode.punycodeDecoded() == jBlockM)
        XCTAssert(jBlockNCode.punycodeDecoded() == jBlockN)
        XCTAssert(jBlockOCode.punycodeDecoded() == jBlockO)
        XCTAssert(jBlockPCode.punycodeDecoded() == jBlockP)
        XCTAssert(jBlockQCode.punycodeDecoded() == jBlockQ)
        XCTAssert(jBlockRCode.punycodeDecoded() == jBlockR)

        XCTAssert(multiscalarCode.punycodeDecoded() == multiscalar)
        XCTAssert(plainCode.punycodeDecoded() == plain)

        XCTAssert(idnaCode.idnaDecoded() == idna)
    }

    static var allTests = [
        ("testEncodingCorrectness", testEncodingCorrectness),
        ("testDecodingCorrectness", testDecodingCorrectness)
    ]
}
