# swift-email

Use this package when an app sends or reads email. The `Email` product gives you the `Email` type from swift-email-standard together with swift-html and Dependencies in one import, plus `StringBuilder` for writing plain text bodies line by line. To read a message you received, start from `Email.Received` in the `Email Received` product. If you only need the email types, use swift-email-standard. To write the HTML body as views, or to produce an Apple Mail message file, use swift-email-html.

## Laws

- `StringBuilder` joins each line and each loop iteration with a newline. An `if` without `else` that doesn't run still adds an empty line, so the result ends in a newline.
- `Email.Received` never fails to parse. Malformed parts show up as missing values, not errors.
- Header text is decoded the same way everywhere. RFC 2047 encoded words decode in their own charset. Octets outside encoded words are read as UTF-8, and as Windows-1252 if they aren't valid UTF-8. An encoded word that can't be decoded is kept as written.
- `Email.Received.text` and `Email.Received.html` are the first plain and HTML text parts that aren't attachments. The search goes through nested multiparts and into forwarded messages. A body decodes in its declared charset. With no charset, or one that isn't known, it falls back to UTF-8 and then Windows-1252.
- A part is an attachment when its disposition is `attachment`, or when it isn't text at all, so an inline image counts. A text part counts only if it has both a `Content-Disposition` and a filename.
- An attachment's filename comes from the `filename` disposition parameter, with RFC 2231 continuations and charsets, and otherwise from the `name` parameter of its content type. Encoded words in either are decoded.
- `Email.Received.attachments` holds only attachments whose transfer encoding decodes. The rest are counted by `Email.Received.undecodableAttachmentCount`.
- `Email.Received.addresses(_:)` matches the header name without regard to case and lowercases every address it returns. It returns nothing at all when the header is missing or appears more than once, when it holds a group, or when any one mailbox is not a valid address. Comments and display names, quoted or encoded, are never read as addresses.
