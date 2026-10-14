public import Email_Standard
public import RFC_2046

extension Email {

    public struct Received: Sendable, Hashable {

        public let entity: RFC_2046.Entity

        public init(entity: RFC_2046.Entity) {
            self.entity = entity
        }
    }
}
