public import Email_Standard
import Byte
import RFC_2045
import RFC_2046
import RFC_2046_Coder
import RFC_2183
import RFC_2231

extension Email.Received {

    public var undecodableAttachmentCount: Int {
        leaves.filter { Self.isAttachment($0) && $0.content == nil }.count
    }

    public var attachments: [Email.Received.Attachment] {
        leaves.filter(Self.isAttachment).compactMap { leaf in
            leaf.content.map { content in
                Email.Received.Attachment(filename: Self.filename(leaf), contentType: leaf.contentType, content: content)
            }
        }
    }

    static func disposition(_ leaf: RFC_2046.Entity) -> RFC_2183.ContentDisposition? {
        leaf["Content-Disposition"].flatMap { value in
            do throws(RFC_2183.ContentDisposition.Error) {
                return try RFC_2183.ContentDisposition(ascii: value)
            } catch {
                return nil
            }
        }
    }

    static func isAttachment(_ leaf: RFC_2046.Entity) -> Bool {
        let disposition = Self.disposition(leaf)
        switch (disposition?.type.rawValue.lowercased(), leaf.contentType.type.lowercased()) {
        case ("attachment", _): return true
        case (_, "text"): return filename(leaf) != nil && disposition != nil
        default: return true
        }
    }

    static func filename(_ leaf: RFC_2046.Entity) -> String? {
        let disposition = Self.disposition(leaf)
        let fromDisposition: [(name: String, value: String)] =
            (disposition?.filename.map { [(name: "filename", value: $0.rawValue)] } ?? [])
            + (disposition?.parameters.extensionParameters.map { (name: $0.key.rawValue, value: $0.value.rawValue) } ?? [])
        let fromType = leaf.contentType.parameters.map { (name: $0.key.rawValue, value: $0.value) }
        return parameter("filename", fromDisposition) ?? parameter("name", fromType)
    }

    static func parameter(_ name: String, _ pairs: [(name: String, value: String)]) -> String? {
        do throws(RFC_2231.Parameter.Error) {
            return try RFC_2231.Parameters(pairs)[name].map { parameter in
                Email.Received.Decoding.header(
                    [Byte](utf8: Email.Received.Decoding.text(parameter.value, charset: parameter.charset?.rawValue))
                )
            }
        } catch {
            return nil
        }
    }
}
