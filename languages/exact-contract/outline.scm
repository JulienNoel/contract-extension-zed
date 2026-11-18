; Declarations and component members. Contract nests by indentation, which the
; shallow grammar does not record, so the outline is a flat list in file order.

(line
  .
  (identifier) @context
  (#any-of? @context
    "component" "shape" "style" "keyframes" "timeline" "decoration" "atom"
    "members" "routes" "action" "task" "sequence")
  .
  (identifier) @name) @item

(line
  .
  (identifier) @context
  (#any-of? @context "fn" "source" "action")
  .
  (call
    function: (function_name) @name)) @item

(line
  .
  (identifier) @context
  (#any-of? @context "test" "font" "sound")
  .
  (string) @name) @item

(line
  .
  (identifier) @context
  (#any-of? @context "theme" "view" "props" "inject" "provide")
  .) @item
