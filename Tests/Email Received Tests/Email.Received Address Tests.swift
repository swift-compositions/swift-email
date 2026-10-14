import Byte
import Email_Received
import Email_Standard
import Testing

extension Email.Received.Test.`Edge Case` {
    @Test func `duplicate From headers are ambiguous`() {
        let message = Email.Received([Byte](utf8: "From: bill@allowed.example\r\nFrom: client@other.example\r\n\r\nbody"))
        #expect(message.addresses("From").isEmpty)
    }

    @Test(arguments: [
        (#""local<bill@allowed.example>"@other.example"#, []),
        (#"<"local<bill@allowed.example>"@other.example>"#, []),
        (#""Billing <bill@allowed.example>" <person@other.example>"#, ["person@other.example"]),
        ("Billing (bill@allowed.example) <person@other.example>", ["person@other.example"]),
        ("bill@allowed.example, person@other.example", ["bill@allowed.example", "person@other.example"]),
        ("<bill@allowed.example> trailing", []),
        ("=?UTF-8?Q?=3Cbill=40allowed.example=3E?= <person@other.example>", ["person@other.example"]),
    ])
    func `only syntactic mailbox addresses are returned`(_ header: String, _ expected: [String]) {
        let message = Email.Received([Byte](utf8: "From: \(header)\r\n\r\nbody"))
        #expect(message.addresses("From") == expected)
    }
    @Test func `undecodable attachments remain visible as failures`() {
        let message = Email.Received([Byte](utf8: "Content-Type: application/pdf\r\nContent-Transfer-Encoding: base64\r\n\r\n!invalid!"))
        #expect(message.attachments.isEmpty)
        #expect(message.undecodableAttachmentCount == 1)
    }

}
