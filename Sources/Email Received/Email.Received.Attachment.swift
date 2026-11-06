#if EmailReceived
    public import Byte
    public import Email_Standard
    public import RFC_2045

    extension Email.Received {

        public struct Attachment: Sendable, Hashable {

            // swift-linter:disable:next raw concept
            // REASON: a sender's attachment name after decoding, shown to the reader and never opened as given; looked at RFC_2183.Filename, which is ASCII only and refuses the café.pdf this target's tests expect, and Path.Component, which refuses separators and control characters a sender may send.
            public let filename: String?

            public let contentType: RFC_2045.ContentType

            public let content: [Byte]

            // swift-linter:disable:next raw concept
            // REASON: a sender's attachment name after decoding, shown to the reader and never opened as given; looked at RFC_2183.Filename, which is ASCII only and refuses the café.pdf this target's tests expect, and Path.Component, which refuses separators and control characters a sender may send.
            public init(filename: String?, contentType: RFC_2045.ContentType, content: [Byte]) {
                self.filename = filename
                self.contentType = contentType
                self.content = content
            }
        }
    }
#endif
