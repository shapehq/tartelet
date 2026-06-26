import Foundation

/// Splits a command-option string into argv elements the way a POSIX shell would,
/// honoring single quotes, double quotes, and backslash escapes.
///
/// Used to forward `TARTELET_RUN_OPTIONS` to `tart run` as separate arguments:
/// appending the raw string as a single argument makes `tart` reject it as one
/// unknown option (e.g. `--net-softnet --net-softnet-allow=…`). Naive splitting on
/// spaces would in turn corrupt any value containing a quoted space, such as a
/// `--dir=` mount whose path has spaces.
enum ShellWordSplitter {
    static func split(_ string: String) -> [String] {
        var words: [String] = []
        var current = ""
        // Tracks whether the current run of characters has started a word, so an
        // explicit empty quote ("" or '') still yields one empty argument.
        var hasWord = false
        var quote: Character?
        var escaped = false

        for character in string {
            if escaped {
                current.append(character)
                escaped = false
                continue
            }

            switch quote {
            case "'":
                // Single quotes are literal: no escapes, no nesting.
                if character == "'" {
                    quote = nil
                } else {
                    current.append(character)
                }
            case "\"":
                // Double quotes allow backslash to escape the next character.
                if character == "\\" {
                    escaped = true
                } else if character == "\"" {
                    quote = nil
                } else {
                    current.append(character)
                }
            default:
                switch character {
                case "'", "\"":
                    quote = character
                case "\\":
                    escaped = true
                case " ", "\t", "\n", "\r":
                    if hasWord {
                        words.append(current)
                        current = ""
                        hasWord = false
                    }
                    continue
                default:
                    current.append(character)
                }
            }
            hasWord = true
        }

        if hasWord {
            words.append(current)
        }
        return words
    }
}
