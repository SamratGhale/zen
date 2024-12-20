package zen

import "core:fmt"
import tt "core:testing"

/* A `Token` or nil. */
@(private = "file")
MaybeToken :: union {
	Token,
}

/* Check if two slices of `Token`s are the same. */
@(private = "file")
expect_tokens_equal :: proc(
	want: []Token,
	got: []Token,
) -> (
	ok: bool,
	err_wanted: MaybeToken,
	err_recieved: MaybeToken,
) {
	got := got
	for i in want {
		if len(got) == 0 do break

		if i != got[0] {
			return false, i, got[0]
		}
		got = got[1:]
	}

	return true, nil, nil
}

/* A basic test of the lexer. */
@(test)
test_lexer_default :: proc(t: ^tt.T) {
	source := `// this is a comment
func foo() {
    if not false {
        print str
    }
}

func add(a, b) => a + b

func test() {
    foo("just a little lexer exercise")
    println(add(1, 2))
}`

	lx := init_lexer(source)
	got, ok := lex(&lx)
	if !ok {
		tt.fail_now(t, "lexer error")
	}
	defer delete(got)

	want := []Token {
		Token{type = .FUNC, lexeme = "func", line = 2},
		Token{type = .IDENT, lexeme = "foo", line = 2},
		Token{type = .LPAREN, lexeme = "(", line = 2},
		Token{type = .RPAREN, lexeme = ")", line = 2},
		Token{type = .LSQUIRLY, lexeme = "{", line = 2},
		Token{type = .IF, lexeme = "if", line = 3},
		Token{type = .NOT, lexeme = "not", line = 3},
		Token{type = .FALSE, lexeme = "false", line = 3},
		Token{type = .LSQUIRLY, lexeme = "{", line = 3},
		Token{type = .PRINT, lexeme = "print", line = 4},
		Token{type = .IDENT, lexeme = "str", line = 4},
		Token{type = .SEMI, lexeme = ";", line = 4},
		Token{type = .RSQUIRLY, lexeme = "}", line = 5},
		Token{type = .SEMI, lexeme = ";", line = 5},
		Token{type = .RSQUIRLY, lexeme = "}", line = 6},
		Token{type = .SEMI, lexeme = ";", line = 6},
		Token{type = .FUNC, lexeme = "func", line = 8},
		Token{type = .IDENT, lexeme = "add", line = 8},
		Token{type = .LPAREN, lexeme = "(", line = 8},
		Token{type = .IDENT, lexeme = "a", line = 8},
		Token{type = .COMMA, lexeme = ",", line = 8},
		Token{type = .IDENT, lexeme = "b", line = 8},
		Token{type = .RPAREN, lexeme = ")", line = 8},
		Token{type = .FAT_ARROW, lexeme = "=>", line = 8},
		Token{type = .IDENT, lexeme = "a", line = 8},
		Token{type = .PLUS, lexeme = "+", line = 8},
		Token{type = .IDENT, lexeme = "b", line = 8},
		Token{type = .SEMI, lexeme = ";", line = 8},
		Token{type = .FUNC, lexeme = "func", line = 10},
		Token{type = .IDENT, lexeme = "test", line = 10},
		Token{type = .LPAREN, lexeme = "(", line = 10},
		Token{type = .RPAREN, lexeme = ")", line = 10},
		Token{type = .LSQUIRLY, lexeme = "{", line = 10},
		Token{type = .IDENT, lexeme = "foo", line = 11},
		Token{type = .LPAREN, lexeme = "(", line = 11},
		Token{type = .STRING, lexeme = "\"just a little lexer exercise\"", line = 11},
		Token{type = .RPAREN, lexeme = ")", line = 11},
		Token{type = .SEMI, lexeme = ";", line = 11},
		Token{type = .IDENT, lexeme = "println", line = 12},
		Token{type = .LPAREN, lexeme = "(", line = 12},
		Token{type = .IDENT, lexeme = "add", line = 12},
		Token{type = .LPAREN, lexeme = "(", line = 12},
		Token{type = .NUMBER, lexeme = "1", line = 12},
		Token{type = .COMMA, lexeme = ",", line = 12},
		Token{type = .NUMBER, lexeme = "2", line = 12},
		Token{type = .RPAREN, lexeme = ")", line = 12},
		Token{type = .RPAREN, lexeme = ")", line = 12},
		Token{type = .SEMI, lexeme = ";", line = 12},
		Token{type = .RSQUIRLY, lexeme = "}", line = 13},
		Token{type = .EOF, lexeme = "", line = 13},
	}

	are_equal, wanted, recieved := expect_tokens_equal(want, got)
	if !are_equal {
		tt.fail_now(t, fmt.tprintf("want %s, got %s", wanted, recieved))
	}
}

/* Test chained multiline method calls for the lexer. */
@(test)
test_lexer_chained_calls :: proc(t: ^tt.T) {
	source := `some_string
    .reverse()
    .capitalize();`

	lx := init_lexer(source)
	got, ok := lex(&lx)
	if !ok {
		tt.fail_now(t, "lexer error")
	}
	defer delete(got)

	want := []Token {
		Token{type = .IDENT, lexeme = "some_string", line = 1},
		Token{type = .DOT, lexeme = ".", line = 2},
		Token{type = .IDENT, lexeme = "reverse", line = 2},
		Token{type = .LPAREN, lexeme = "(", line = 2},
		Token{type = .RPAREN, lexeme = ")", line = 2},
		Token{type = .DOT, lexeme = ".", line = 3},
		Token{type = .IDENT, lexeme = "capitalize", line = 3},
		Token{type = .LPAREN, lexeme = "(", line = 3},
		Token{type = .RPAREN, lexeme = ")", line = 3},
		Token{type = .SEMI, lexeme = ";", line = 3},
	}

	are_equal, wanted, recieved := expect_tokens_equal(want, got)
	if !are_equal {
		tt.fail_now(t, fmt.tprintf("want %s, got %s", wanted, recieved))
	}
}
