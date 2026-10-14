public import Byte
public import Email_Standard
import RFC_2046
import RFC_2046_Coder

extension Email.Received {

    public init(_ bytes: some Swift::Collection<Byte>) {
        self.init(entity: RFC_2046.Entity(binary: bytes))
    }
}
