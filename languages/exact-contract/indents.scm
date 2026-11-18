; Brackets continue a logical line across newlines. Block indentation after
; `component`, `if`, `view`, … comes from increase_indent_pattern in config.toml,
; since Contract's blocks are made by indentation, not by tokens.
(arguments ")" @end) @indent
(list "]" @end) @indent
(braces "}" @end) @indent
