import XCTest
@testable import VirtualMachineData

final class ShellWordSplitterTests: XCTestCase {
    func testEmptyStringYieldsNoWords() {
        XCTAssertEqual(ShellWordSplitter.split(""), [])
    }

    func testWhitespaceOnlyYieldsNoWords() {
        XCTAssertEqual(ShellWordSplitter.split("   \t \n "), [])
    }

    func testSingleWord() {
        XCTAssertEqual(ShellWordSplitter.split("--net-softnet"), ["--net-softnet"])
    }

    func testSplitsOnWhitespace() {
        XCTAssertEqual(
            ShellWordSplitter.split("--net-softnet --net-softnet-allow=192.168.2.0/24"),
            ["--net-softnet", "--net-softnet-allow=192.168.2.0/24"]
        )
    }

    func testCollapsesRunsOfWhitespace() {
        XCTAssertEqual(
            ShellWordSplitter.split("  a\t\tb   c  "),
            ["a", "b", "c"]
        )
    }

    func testDoubleQuotesPreserveSpaces() {
        XCTAssertEqual(
            ShellWordSplitter.split("--dir=\"cache:/My Mount\""),
            ["--dir=cache:/My Mount"]
        )
    }

    func testSingleQuotesPreserveSpaces() {
        XCTAssertEqual(
            ShellWordSplitter.split("'a b c'"),
            ["a b c"]
        )
    }

    func testSingleQuotesAreLiteral() {
        XCTAssertEqual(
            ShellWordSplitter.split("'a\\b'"),
            ["a\\b"]
        )
    }

    func testBackslashEscapesSpace() {
        XCTAssertEqual(
            ShellWordSplitter.split("a\\ b"),
            ["a b"]
        )
    }

    func testBackslashEscapesQuoteCharacter() {
        XCTAssertEqual(
            ShellWordSplitter.split("a\\\"b"),
            ["a\"b"]
        )
    }

    func testEscapedQuoteInsideDoubleQuotes() {
        XCTAssertEqual(
            ShellWordSplitter.split("\"a\\\"b\""),
            ["a\"b"]
        )
    }

    func testAdjacentQuotedAndUnquotedConcatenate() {
        XCTAssertEqual(
            ShellWordSplitter.split("--label='self hosted'macos"),
            ["--label=self hostedmacos"]
        )
    }

    func testEmptyQuotesYieldOneEmptyArgument() {
        XCTAssertEqual(ShellWordSplitter.split("''"), [""])
        XCTAssertEqual(ShellWordSplitter.split("\"\""), [""])
    }
}
