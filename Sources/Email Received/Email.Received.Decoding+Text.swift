import ASCII
import Byte
import Email_Standard
import RFC_2045
import RFC_2047
import RFC_2231
import WHATWG_Encoding

extension Email.Received.Decoding {

    static func text(_ octets: [Byte], charset: String?) -> String {
        switch charset.flatMap(WHATWG_Encoding.Encoding.init(label:)) {
        case let encoding?: encoding.decode(octets)
        case nil: raw(octets)
        }
    }

    static func raw(_ octets: [Byte]) -> String {
        let utf8 = WHATWG_Encoding.Encoding.utf8.decode(octets)
        return utf8.unicodeScalars.contains("\u{FFFD}") ? WHATWG_Encoding.Encoding.windows1252.decode(octets) : utf8
    }

    static func header(_ value: [Byte]) -> String {
        RFC_2047.Text(value).segments.map { segment in
            switch segment {
            case .text(let octets):
                raw(octets)
            case .word(let word):
                Self.word(word)
            }
        }.joined()
    }

    static func word(_ word: RFC_2047.EncodedWord) -> String {
        do throws(RFC_2047.EncodedWord.Error) {
            return text(try word.octets, charset: RFC_2231.Charset(word.charset).name.rawValue)
        } catch {
            return String(decoding: word.text.map(\.byte.bitPattern), as: UTF8.self)
        }
    }
}
