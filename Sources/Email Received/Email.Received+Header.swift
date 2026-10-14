public import Email_Standard
import RFC_2046

extension Email.Received {

    public func header(_ name: String) -> String? {
        entity[name].map(Email.Received.Decoding.header)
    }

    public var subject: String? {
        header("Subject")
    }

}
