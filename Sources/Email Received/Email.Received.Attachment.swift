#if EmailReceived
    public import Byte
    public import Email_Standard
    public import RFC_2045

    extension Email.Received {

        public struct Attachment: Sendable, Hashable {

            public let filename: String?

            public let contentType: RFC_2045.ContentType

            public let content: [Byte]

            public init(filename: String?, contentType: RFC_2045.ContentType, content: [Byte]) {
                self.filename = filename
                self.contentType = contentType
                self.content = content
            }
        }
    }
#endif
