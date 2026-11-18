/**
 * Tree-sitter grammar for Exact's Contract language (`.contract` files).
 *
 * Contract is indentation-based and keeps almost no reserved words, so this
 * grammar is deliberately shallow: a file is a run of logical lines, and each
 * line is a run of items (names, literals, calls, `name=` attributes, `name:`
 * fields, bracket groups). The highlight queries classify words by where they
 * sit (first word of a line, the word after a declaration keyword, an
 * attribute name, a callee) the way the VS Code TextMate grammar in
 * `editors/vscode` does. That keeps the parser error-free on any input and
 * needs no external scanner.
 *
 * Lexical rules follow docs/contract-grammar.md, "Lexical rules".
 */

const NAME = /[A-Za-z_](?:[A-Za-z0-9_]|-[A-Za-z])*/;

module.exports = grammar({
  name: 'exact_contract',

  extras: $ => [/[ \t\f\uFEFF]/, $.comment],

  conflicts: $ => [],

  rules: {
    source_file: $ => seq(
      repeat(choice(seq($.line, $._newline), $._newline)),
      optional($.line),
    ),

    _newline: _ => /\r?\n/,

    // A state part (`:hover`) or a pseudo-element part (`::placeholder`) is a
    // whole line of its own.
    line: $ => choice(
      seq($.pseudo_class, repeat($._item)),
      repeat1($._item),
    ),

    _item: $ => choice(
      $.attribute,
      $.field,
      $.call,
      $.member_access,
      $.method_call,
      $.pseudo_element,
      $.identifier,
      $.number,
      $.string,
      $.template_string,
      $.color,
      $.custom_property,
      $.arguments,
      $.list,
      $.braces,
      $._operator,
      ',',
    ),

    // Inside brackets, newlines continue the logical line.
    _group_item: $ => choice($._item, $._newline),

    identifier: _ => NAME,

    // CSS vendor-prefixed attribute names (`-exact-tint-color=`).
    vendor_identifier: _ => /-(?:exact|webkit|moz|ms|apple)-[A-Za-z](?:[A-Za-z0-9_]|-[A-Za-z])*/,

    // `name=` — an element attribute, a named argument, a binding, or an
    // assignment in an action.
    attribute: $ => prec(2, seq(
      field('name', alias(choice($.identifier, $.vendor_identifier), $.attribute_name)),
      '=',
    )),

    // `name:` — a shape field, a typed parameter, a type annotation.
    field: $ => prec(2, seq(
      field('name', alias($.identifier, $.field_name)),
      ':',
    )),

    call: $ => prec(2, seq(
      field('function', alias($.identifier, $.function_name)),
      field('arguments', $.arguments),
    )),

    method_call: $ => prec(3, seq(
      '.',
      field('method', alias($.identifier, $.function_name)),
      field('arguments', $.arguments),
    )),

    member_access: $ => prec(2, seq(
      '.',
      field('member', alias($.identifier, $.member_name)),
    )),

    pseudo_class: $ => prec(3, seq(':', alias($.identifier, $.pseudo_name))),

    pseudo_element: $ => seq('::', alias($.identifier, $.pseudo_name)),

    arguments: $ => seq('(', repeat($._group_item), ')'),
    list: $ => seq('[', repeat($._group_item), ']'),
    braces: $ => seq('{', repeat($._group_item), '}'),

    _operator: _ => choice(
      '==', '!=', '<=', '>=', '&&', '||', '=>',
      '=', ':', '+', '-', '*', '/', '%', '!', '?', '<', '>', '.',
    ),

    number: _ => /\d+(?:\.\d+)?(?:[eE][+-]?\d+)?/,

    // A bare hex colour, as CSS writes it: #1f9d62.
    color: _ => /#[0-9A-Fa-f]{3,8}/,

    // A CSS custom property or colour profile name: --brand.
    custom_property: _ => /--[A-Za-z_](?:[A-Za-z0-9_]|-[A-Za-z])*/,

    string: $ => seq(
      '"',
      repeat(choice($.escape_sequence, $._string_content)),
      token.immediate('"'),
    ),

    _string_content: _ => token.immediate(prec(1, /[^"\\\r\n]+/)),

    template_string: $ => seq(
      '`',
      repeat(choice($.escape_sequence, $.interpolation, $._template_content)),
      token.immediate('`'),
    ),

    _template_content: _ => token.immediate(prec(1, /[^`\\$\r\n]+|\$/)),

    interpolation: $ => seq(
      token.immediate(prec(3, '${')),
      repeat($._group_item),
      '}',
    ),

    escape_sequence: _ => token.immediate(prec(2, choice(
      /\\[nt"\\`$]/,
      /\\u\{[0-9A-Fa-f]{1,6}\}/,
      /\\u[0-9A-Fa-f]{4}/,
      /\\./,
    ))),

    comment: _ => token(seq('//', /[^\r\n]*/)),
  },
});
