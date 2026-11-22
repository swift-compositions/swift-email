#if EmailReceived
    public import Email_Standard
    public import RFC_2046

    extension Email {

        public struct Received: Sendable, Hashable {

            public let entity: IETF.RFC.`2046`.Entity

            public init(entity: IETF.RFC.`2046`.Entity) {
                self.entity = entity
            }
        }
    }
#endif
