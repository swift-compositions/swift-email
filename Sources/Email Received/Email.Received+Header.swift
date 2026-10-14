public import Email_Standard
import RFC_2046

extension Email.Received {

    public func header(_ name: String) -> String? {
        entity[name].map(Email.Received.Decoding.header)
    }

    public var subject: String? {
        header("Subject")
    }

    public func addresses(_ name: String) -> [String] {
        guard let value = header(name) else { return [] }
        let bracketed = value.split(separator: "<").dropFirst().compactMap { $0.split(separator: ">").first }
        let candidates = bracketed.isEmpty ? value.split(separator: ",").map { $0.split(separator: " ").last ?? $0 } : bracketed
        return candidates
            .map { $0.trimmingCharacters(in: " \t\"'") }
            .filter { $0.contains("@") }
            .map { $0.lowercased() }
    }
}

extension Substring {

    fileprivate func trimmingCharacters(in set: String) -> String {
        String(drop { set.contains($0) }.reversed().drop { set.contains($0) }.reversed())
    }
}
