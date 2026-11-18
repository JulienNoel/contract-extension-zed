; Exact Contract highlights.
;
; The grammar is shallow (lines of items), so most classification happens
; here, by position, mirroring editors/vscode/syntaxes/exact-contract.tmLanguage.json
; in the Exact repo. Zed lets later patterns win, so general rules come first
; and positional rules (first word of a line, word after a keyword) come last.

; ---------------------------------------------------------------------------
; General

(identifier) @variable

((identifier) @type
  (#match? @type "^[A-Z]"))

(field_name) @property
(member_name) @property
(attribute_name) @attribute
(pseudo_name) @attribute

(function_name) @function
((function_name) @type
  (#match? @type "^[A-Z]"))

(number) @number
(color) @constant
(custom_property) @variable.special

(string) @string
(template_string) @string
(escape_sequence) @string.escape

(interpolation
  "${" @punctuation.special
  "}" @punctuation.special)

(comment) @comment

; ---------------------------------------------------------------------------
; Words with a fixed meaning wherever they appear as a bare name

((identifier) @boolean
  (#any-of? @boolean "true" "false"))

((identifier) @constant
  (#eq? @constant "none"))

((identifier) @keyword
  (#any-of? @keyword "and" "or" "not"))

((identifier) @keyword
  (#any-of? @keyword
    "when" "if" "else" "for" "in" "match" "case" "as" "fn" "shape" "mount"
    "from" "to" "then" "refreshes" "with" "key" "children" "persist"
    "transient" "keep" "queue" "parallel" "every" "after" "frame" "writes"))

((identifier) @type
  (#any-of? @type "number" "string" "bool" "unit" "option" "enum" "action"))

((function_name) @function
  (#eq? @function "some"))

; A return type right before `=`: fn f(x: number): string = …
((attribute_name) @type
  (#any-of? @type "number" "string" "bool" "unit"))

; Event attributes (press=, change=, key=, …) read as handlers.
((attribute_name) @function
  (#any-of? @function
    "press" "change" "input" "cancel" "close" "toggle" "select" "hover"
    "focus" "blur" "focusin" "focusout" "key" "keycapture" "keyup" "submit"
    "load" "message" "contextmenu" "delete" "dblclick" "swiperight"
    "swipeleft" "refresh" "scroll" "scrollend" "scrolldragstart"
    "scrolldragend" "pan" "panrelease" "loadedmetadata" "durationchange"
    "fullscreenchange" "enterpictureinpicture" "leavepictureinpicture"
    "pictureinpictureerror" "timeupdate" "play" "playing" "pause" "ended"
    "waiting" "seeking" "seeked" "ratechange" "volumechange" "error"
    "canplay" "seekbackward" "seekforward" "seekto" "previoustrack"
    "nexttrack" "stop" "navigate" "historyswipe" "currententrychange"
    "navigatesuccess" "navigateerror" "newwindow" "download" "capture"
    "userpromptopened" "heightrelease" "transformgeometry"
    "transformrelease" "reorderdrop" "reachstart" "reachend" "beforeunload"
    "midimessage" "beforeinput" "copy" "cut" "drop" "dragenter" "dragleave"
    "atompress" "paste" "pointerdown" "pointermove" "pointerup" "resize"
    "intersect" "selectionchange" "wheel"))

; ---------------------------------------------------------------------------
; First word of a line

; Declarations, component sections and statements.
(line
  .
  (identifier) @keyword
  (#any-of? @keyword
    "use" "shape" "fn" "source" "style" "decoration" "atom" "keyframes" "font"
    "sound" "theme" "timeline" "color-profile" "routes" "component" "members"
    "test" "props" "inject" "provide" "slot" "state" "derive" "resource"
    "mutation" "action" "task" "sequence" "view" "let" "send" "refresh"
    "change" "play" "tab" "notfound"))

; Authored test steps and launch lines.
(line
  .
  (identifier) @keyword
  (#any-of? @keyword
    "tap" "type" "pick" "authorize" "clock" "prefer" "reload" "fail" "pass"
    "request" "back" "screenshot" "perf" "expect" "size" "epoch" "time-zone"
    "at" "locale" "seed" "fresh" "before"))

; Built-in view tags.
(line
  .
  (identifier) @tag
  (#any-of? @tag
    "box" "column" "row" "dialog" "hr" "main" "header" "nav" "section"
    "footer" "article" "aside" "table" "caption" "thead" "tbody" "tfoot" "tr"
    "th" "td" "dl" "dt" "dd" "list" "scroll" "text" "button" "link"
    "textarea" "input" "canvas" "iframe" "video" "audio" "image" "svg"
    "symbol" "marker" "mask" "pattern" "foreignObject" "filter" "feBlend"
    "feColorMatrix" "feComponentTransfer" "feComposite" "feConvolveMatrix"
    "feDiffuseLighting" "feDisplacementMap" "feDropShadow" "feFlood"
    "feFuncR" "feFuncG" "feFuncB" "feFuncA" "feGaussianBlur" "feMerge"
    "feMergeNode" "feMorphology" "feOffset" "feSpecularLighting" "feTile"
    "feTurbulence" "feDistantLight" "fePointLight" "feSpotLight" "tspan"
    "defs" "linearGradient" "radialGradient" "stop" "clipPath" "g" "path"
    "polyline" "polygon" "circle" "ellipse" "line" "rect" "select" "option"
    "progress" "time" "head" "markup" "atoms"))

; Native (hyphenated) tags: apple-map, web-view, …
(line
  .
  (identifier) @tag
  (#match? @tag "^[a-z][A-Za-z0-9_]*(-[A-Za-z][A-Za-z0-9_]*)+$")
  (#not-any-of? @tag "color-profile" "time-zone"))

; A component use at the start of a line: Card(title="…")
(line
  .
  (call
    function: (function_name) @type
    (#match? @type "^[A-Z]")))

; ---------------------------------------------------------------------------
; The name a declaration introduces

(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword
    "component" "shape" "style" "keyframes" "timeline" "decoration" "atom"
    "members")
  .
  (identifier) @type)

(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword "routes" "mutation" "refresh" "send")
  .
  (identifier) @variable)

(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword "action" "task" "sequence")
  .
  (identifier) @function)

(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword "action" "fn" "source")
  .
  (call
    function: (function_name) @function))

(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword "state" "derive" "resource" "let" "send")
  .
  (attribute
    name: (attribute_name) @variable))

(line
  .
  (identifier) @_keyword
  (#eq? @_keyword "state")
  .
  (field
    name: (field_name) @variable))

(line
  .
  (identifier) @_keyword
  (#eq? @_keyword "use")
  (identifier) @type
  (#match? @type "^[A-Z]"))

; `key=` on a `for`, a resource over a list, or a gated task is the row key,
; not the key event.
(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword "for" "resource" "task" "sequence")
  (attribute
    name: (attribute_name) @keyword
    (#eq? @keyword "key")))

; expect state …, expect text …, clock settle, …
(line
  .
  (identifier) @_keyword
  (#any-of? @_keyword "expect" "clock")
  .
  (identifier) @keyword)

; ---------------------------------------------------------------------------
; Punctuation and operators

(pseudo_class ":" @punctuation.special)
(pseudo_element "::" @punctuation.special)

[
  "==" "!=" "<=" ">=" "&&" "||" "=>"
  "=" ":" "+" "-" "*" "/" "%" "!" "?" "<" ">"
] @operator

["(" ")" "[" "]" "{" "}"] @punctuation.bracket

["," "."] @punctuation.delimiter

(string "\"" @string)
(template_string "`" @string)
