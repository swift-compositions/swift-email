import Byte
import Email_Received
import Email_Standard
import RFC_2045
import Testing

extension Email.Received {

    @Suite
    struct Test {

        @Suite
        struct Unit {}

        @Suite
        struct `Edge Case` {}

        static func message(_ lines: [String]) -> Email.Received {
            Email.Received([Byte](utf8: lines.joined(separator: "\r\n")))
        }

        static func message(octets: [UInt8]) -> Email.Received {
            Email.Received(octets.map(Byte.init(bitPattern:)))
        }
    }
}

extension Email.Received.Test.Unit {

    @Test
    func `an encoded subject decodes in its charset`() {
        let message = Email.Received.Test.message([
            "Subject: =?ISO-8859-1?Q?Factuur_caf=E9?= =?UTF-8?B?4oKs?=",
            "",
            "x",
        ])

        #expect(message.subject == "Factuur café€")
    }

    @Test
    func `addresses are extracted from a display name`() {
        let message = Email.Received.Test.message([
            "From: =?UTF-8?Q?Energie_B=2EV=2E?= <Facturen@Example.NL>",
            "To: a@example.com, \"B\" <b@example.com>",
            "",
            "x",
        ])

        #expect(message.addresses("From") == ["facturen@example.nl"])
        #expect(message.addresses("To") == ["b@example.com"])
        #expect(message.header("From") == "Energie B.V. <Facturen@Example.NL>")
    }

    @Test
    func `the plain and html bodies decode with their charsets`() {
        let message = Email.Received.Test.message([
            "Content-Type: multipart/alternative; boundary=b",
            "",
            "--b",
            "Content-Type: text/plain; charset=iso-8859-1",
            "Content-Transfer-Encoding: quoted-printable",
            "",
            "Bedrag =80 12,50",
            "--b",
            "Content-Type: text/html; charset=utf-8",
            "",
            "<p>Bedrag</p>",
            "--b--",
        ])

        #expect(message.text == "Bedrag € 12,50")
        #expect(message.html == "<p>Bedrag</p>")
        #expect(message.attachments.isEmpty)
    }

    @Test
    func `a pdf attachment keeps its decoded content and RFC 2231 name`() {
        let message = Email.Received.Test.message([
            "Content-Type: multipart/mixed; boundary=m",
            "",
            "--m",
            "Content-Type: text/plain",
            "",
            "See attachment",
            "--m",
            "Content-Type: application/pdf",
            "Content-Disposition: attachment; filename*=utf-8''factuur%20oktober.pdf",
            "Content-Transfer-Encoding: base64",
            "",
            "JVBERi0x",
            "--m--",
        ])

        #expect(message.text == "See attachment")
        #expect(message.attachments.count == 1)
        #expect(message.attachments.first?.filename == "factuur oktober.pdf")
        #expect(message.attachments.first?.content == [Byte](utf8: "%PDF-1"))
        #expect(message.attachments.first?.contentType.subtype == "pdf")
    }

    @Test
    func `an encoded word filename and a content type name are read`() {
        let message = Email.Received.Test.message([
            "Content-Type: multipart/mixed; boundary=m",
            "",
            "--m",
            "Content-Type: application/pdf",
            "Content-Disposition: attachment; filename=\"=?UTF-8?B?Y2Fmw6kucGRm?=\"",
            "",
            "x",
            "--m",
            "Content-Type: application/pdf; name=\"nota.pdf\"",
            "",
            "y",
            "--m--",
        ])

        #expect(message.attachments.map(\.filename) == ["café.pdf", "nota.pdf"])
    }

    @Test
    func `a forwarded message contributes its body and attachments`() {
        let message = Email.Received.Test.message([
            "Content-Type: multipart/mixed; boundary=f",
            "",
            "--f",
            "Content-Type: message/rfc822",
            "",
            "Subject: Inner",
            "Content-Type: multipart/mixed; boundary=i",
            "",
            "--i",
            "Content-Type: text/plain",
            "",
            "Inner text",
            "--i",
            "Content-Type: application/pdf; name=a.pdf",
            "",
            "pdf",
            "--i--",
            "--f--",
        ])

        #expect(message.text == "Inner text")
        #expect(message.attachments.map(\.filename) == ["a.pdf"])
    }
}

extension Email.Received.Test.`Edge Case` {

    @Test
    func `a raw latin1 header falls back to windows 1252`() {
        let message = Email.Received.Test.message(octets: Array("Subject: caf".utf8) + [0xE9] + Array("\r\n\r\nx".utf8))

        #expect(message.subject == "café")
    }

    @Test
    func `raw UTF-8 in a header is kept`() {
        #expect(Email.Received.Test.message(["Subject: Rekening – juni", "", "x"]).subject == "Rekening – juni")
    }

    @Test
    func `an unknown charset falls back to the raw octets`() {
        let message = Email.Received.Test.message([
            "Content-Type: text/plain; charset=x-unknown",
            "",
            "plain",
        ])

        #expect(message.text == "plain")
    }

    @Test
    func `a message without a body part has no text`() {
        let message = Email.Received.Test.message(["Content-Type: image/png", "", "x"])

        #expect(message.text == nil)
        #expect(message.attachments.count == 1)
    }

    @Test
    func `a missing header is absent`() {
        #expect(Email.Received.Test.message(["", "x"]).subject == nil)
        #expect(Email.Received.Test.message(["", "x"]).addresses("From").isEmpty)
    }
}
