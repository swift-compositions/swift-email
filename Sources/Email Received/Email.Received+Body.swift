#if EmailReceived
    public import Email_Standard
    import RFC_2045
    import RFC_2046

    extension Email.Received {

        public var text: String? {
            body("plain")
        }

        public var html: String? {
            body("html")
        }

        var leaves: [RFC_2046.Entity] {
            Self.leaves(entity)
        }

        static func leaves(_ entity: RFC_2046.Entity) -> [RFC_2046.Entity] {
            switch entity.body {
            case .discrete: [entity]
            case .multipart(let multipart): multipart.parts.flatMap(leaves)
            case .message(let inner): leaves(inner)
            }
        }

        func body(_ subtype: String) -> String? {
            leaves.first { leaf in
                leaf.contentType.type.lowercased() == "text"
                    && leaf.contentType.subtype.lowercased() == subtype
                    && !Self.isAttachment(leaf)
            }.flatMap { leaf in
                leaf.content.map { Email.Received.Decoding.text($0, charset: leaf.contentType.charset?.rawValue) }
            }
        }
    }
#endif
