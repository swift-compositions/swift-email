import Byte
public import Email_Standard
import RFC_2046
import RFC_5322

extension Email.Received {
    public func addresses(_ name: String) -> [String] {
        guard entity.fields.filter({ $0.name.lowercased() == name.lowercased() }).count == 1,
            let raw = entity[name], let fields = Self.mailboxes(String(decoding: raw.map(\.bitPattern), as: UTF8.self))
        else { return [] }
        var result: [String] = []
        for field in fields {
            guard let address = Self.address(field), !address.contains("<"), !address.contains(">") else { return [] }
            do throws(RFC_5322.Mailbox.Error) {
                result.append(try RFC_5322.Mailbox(address).address.lowercased())
            } catch {
                return []
            }
        }
        return result
    }

    private static func mailboxes(_ raw: String) -> [String]? {
        var fields: [String] = []
        var field = ""
        var quoted = false
        var escaped = false
        var comments = 0
        var angle = false
        for character in raw {
            if escaped {
                if comments == 0 { field.append(character) }
                escaped = false
                continue
            }
            if character == "\\", quoted || comments > 0 {
                if comments == 0 { field.append(character) }
                escaped = true
                continue
            }
            if comments > 0 {
                if character == "(" { comments += 1 }
                if character == ")" { comments -= 1 }
                continue
            }
            if character == "\"" {
                quoted.toggle()
                field.append(character)
                continue
            }
            if !quoted {
                if character == "(" {
                    comments = 1
                    continue
                }
                if character == "<" {
                    guard !angle else { return nil }
                    angle = true
                }
                if character == ">" {
                    guard angle else { return nil }
                    angle = false
                }
                if character == ",", !angle {
                    fields.append(field)
                    field = ""
                    continue
                }
                if character == ":" || character == ";" { return nil }
            }
            field.append(character)
        }
        guard !quoted, !escaped, comments == 0, !angle else { return nil }
        fields.append(field)
        return fields
    }

    private static func address(_ field: String) -> String? {
        var quoted = false
        var escaped = false
        var opening: String.Index?
        var closing: String.Index?
        for index in field.indices {
            let character = field[index]
            if escaped {
                escaped = false
                continue
            }
            if character == "\\", quoted {
                escaped = true
                continue
            }
            if character == "\"" {
                quoted.toggle()
                continue
            }
            if !quoted {
                if character == "<" {
                    guard opening == nil else { return nil }
                    opening = index
                }
                if character == ">" {
                    guard closing == nil else { return nil }
                    closing = index
                }
            }
        }
        let value: Substring
        if let opening, let closing {
            guard opening < closing, field[field.index(after: closing)...].allSatisfy(\.isWhitespace) else { return nil }
            value = field[field.index(after: opening)..<closing]
        } else {
            guard opening == nil, closing == nil else { return nil }
            value = field[...]
        }
        return String(value.drop(while: \.isWhitespace).reversed().drop(while: \.isWhitespace).reversed())
    }
}
