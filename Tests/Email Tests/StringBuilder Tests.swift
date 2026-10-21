//
//  StringBuilderTests.swift
//  swift-email
//
//  Covers the surviving Email surface after the 2026-07-12 parking (see
//  Parked/Email/README.md): the inlined StringBuilder that replaced the
//  retired coenttb/swift-builders dependency (newline-join semantics).
//

import Email
import Testing

extension StringBuilder {
    @Suite
    struct Test {
        @Suite
        struct Unit {}

        @Suite
        struct `Edge Case` {}

        @Suite
        struct Integration {}
    }
}

extension StringBuilder.Test.Unit {
    @Test
    func `lines join with newlines`() {
        @StringBuilder
        func text() -> String {
            "first"
            "second"
        }
        #expect(text() == "first\nsecond")
    }

    @Test
    func `arrays join with newlines`() {
        @StringBuilder
        func text() -> String {
            for word in ["a", "b", "c"] {
                word
            }
        }
        #expect(text() == "a\nb\nc")
    }
}

extension StringBuilder.Test.`Edge Case` {
    @Test
    func `optional and conditional branches build`() {
        @StringBuilder
        func text(include: Bool) -> String {
            "always"
            if include {
                "sometimes"
            }
        }
        #expect(text(include: true) == "always\nsometimes")
        #expect(text(include: false) == "always\n")
    }
}
