
# jaabro

A very dumb PEG parser library.

Brother to [raabro](https://github.com/jmettraux/raabro), son to [aabro](https://github.com/flon-io/aabro), grandson to [neg](https://github.com/jmettraux/neg), grand-grandson to [parslet](https://github.com/kschiess/parslet).


## a sample parser

A parser is made by calling `Jaabro.makeParser` with a function. This function should hold the definitions of the parse functions making up the final parser, and also the rewrite functions used to rewrite the parse tree resulting from the parsing.

A parse function might look like
```js
function fun(i) { return seq('fun', i, funname, funargs); }
```
This `fun` function expects a sequence `funame` then `funargs`. Those two arguments are parse functions themselves. Parse functions generally call a Jaabro function like `seq()`, `rex()`, `eseq()` to compose a bit higher level parser.

Rewrite rules are of the form `rewrite_{tree_name}(tree)`. They take as input a node of a parse tree and return a re-interpretation / rewrite of that tree. By default Jaabro takes the tree_name coming from the parse functions to call the corresponding rewrite functions. For example a parse tree whose root node is "expression" will be handed to `rewrite_expression(tree)`.

Here is a complete example:
```js
var Xelp = Jaabro.makeParser(function() {

  // parse rules

  function pa(i) { return rex(null, i, /\(\s*/); }
  function pz(i) { return rex(null, i, /\)\s*/); }
  function com(i) { return rex(null, i, /,\s*/); }

  function number(i) {
    return rex('number', i, /-?([0-9]*\.[0-9]+|[0-9][,0-9]*[0-9]|[0-9]+)\s*/); }

  function va(i) { return rex('var', i, /[a-z][A-Za-z0-9]*\s*/); }

  function qstring(i) { return rex('qstring', i, /'(\\'|[^'])*'\s*/); }
  function dqstring(i) { return rex('dqstring', i, /"(\\"|[^"])*"\s*/); }
  function string(i) { return alt('string', i, dqstring, qstring); }

  function funargs(i) { return eseq('funargs', i, pa, cmp, com, pz); }
  function funname(i) { return rex('funname', i, /[A-Z][A-Z0-9]*/); }
  function fun(i) { return seq('fun', i, funname, funargs); }

  function comparator(i) { return rex('comparator', i, /([\<\>]=?|=~|!?=)\s*/); }
  function multiplier(i) { return rex('multiplier', i, /[*\/]\s*/); }
  function adder(i) { return rex('adder', i, /[+\-]\s*/); }

  function par(i) { return seq('par', i, pa, cmp, pz); }
  function exp(i) { return alt('exp', i, par, fun, number, string, va); }

  function mul(i) { return jseq('mul', i, exp, multiplier); }
  function add(i) { return jseq('add', i, mul, adder); }

  function rcmp(i) { return seq('rcmp', i, comparator, add); }
  function cmp(i) { return seq('cmp', i, add, rcmp, '?'); }

  var root = cmp; // tells Jaabro where to start

  // rewrite rules
  //
  // one rule per possible parse tree name above

  function rewrite_cmp(t) {

    if (t.children.length === 1) return rewrite(t.children[0]);

    return [
      'cmp',
      t.children[1].children[0].string().trim(),
      rewrite(t.children[0]),
      rewrite(t.children[1].children[1])
    ];
  }

  function rewrite_add(t) {

    if (t.children.length === 1) return rewrite(t.children[0]);

    var cn = t.children.slice(); // dup array
    var a = [ t.name === 'add' ? 'SUM' : 'MUL' ];
    var mod = null;
    var c = null;

    while (c = cn.shift()) {
      var v = rewrite(c);
      if (mod) v.push(mod)
      a.push(v);
      c = cn.shift(); if ( ! c) break;
      //mod = { '-': 'opp', '/': 'inv' }[c.string().trim()];
      mod = { '-': 'opp', '/': 'inv' }[c.strinp()];
    }

    return a;
  }
  var rewrite_mul = rewrite_add;

  function rewrite_fun(t) {

    //var a = [ t.children[0].string() ];
    var a = [ t.children[0].strinp() ];
    t.children[1].children.forEach(function(c) {
      if (c.name) a.push(rewrite(c));
    });

    return a;
  }

  function rewrite_exp(t) { return rewrite(t.children[0]); }

  function rewrite_par(t) { return rewrite(t.children[1]); }

  //function rewrite_var(t) { return [ 'var', t.string().trim() ]; }
  //function rewrite_number(t) { return [ 'num', t.string().trim() ]; }
  function rewrite_var(t) { return [ 'var', t.strinp() ]; }
  function rewrite_number(t) { return [ 'num', t.strinp() ]; }

  function rewrite_string(t) {

    //var s = t.children[0].string().trim();
    var s = t.children[0].strinp();
    var q = s[0];
    var s = s.slice(1, -1);

    return [
      'str', q === '"' ? s.replace(/\\\"/g, '"') : s.replace(/\\'/g, "'") ];
  }
});
```

then

```js
Xelp.parse('10 + IF(c10 = "yes", 11, 0)');
  // -- yields -->
["SUM",["num","9"],["num","1"]]

Xelp.parse('10 + IF(c10 = "yes", 11, 0)');
  // -- yields -->
["SUM",
  ["num","10"],
  ["IF",
    ["cmp","=",["var","c10"],["str","yes"]],
    ["num","11"],
    ["num","0"]]]
```

## basic parsers

The first parameter is the name used by rewrite rules.
The second parameter is a `Jaabro.Input` instance, mostly a wrapped string.

```js
function str(name, input, string)
  // matching a string

function rex(name, input, regex_or_string)
  // matching a regexp
  // no need for ^ or \A, checks the match occurs at current offset

function seq(name, input, parser0, parser1, ...)
  // a sequence of parsers

function alt(name, input, parser0, parser1, ...)
  // tries the parsers returns as soon as one succeeds

function altg(name, input, parser0, parser1, ...)
  // tries all the parsers, returns with the longest match

function rep(name, input, parser, min, max=0)
  // repeats the the wrapped parser

function ren(name, input, parser)
  // renames the output of the wrapped parser

function jseq(name, input, eltpa, seppa)
  //
  // seq(name, input, eltpa, seppa, eltpa, seppa, eltpa, seppa, ...)
  //
  // a sequence of `eltpa` parsers separated (joined) by `seppa` parsers

function eseq(name, input, startpa, eltpa, seppa, endpa)
  //
  // seq(name, input, startpa, eltpa, seppa, eltpa, seppa, ..., endpa)
  //
  // a sequence of `eltpa` parsers separated (joined) by `seppa` parsers
  // preceded by a `startpa` parser and followed by a `endpa` parser

function nott(name, input, parser)
  // tries the given parser and succeeds if that parser fails, a kind of "not"
```

## the `seq` parser and its quantifiers

`seq` is special, it understands "quantifiers": `'?'`, `'+'` or `'*'`. They make behave `seq` a bit like a classical regex.

There is a `'!'` quantifier which is documented at the end of this section.

```javascript
var CartParser = Jaabro.makeParser(function() {

  function pa(i) {
    return rex(null, i, /\(\s*/); }

  function fruit(i) {
    return rex('fruit', i, /(tomato|apple|orange)/); }
  function vegetable(i) {
    return rex('vegetable', i, /(potato|cabbage|carrot)/); }

  function cart(i) {
    return seq('cart', i, fruit, '*', vegetable, '*'); }
      // zero or more fruits followed by zero or more vegetables
});
```

(Yes, this sample parser parses string like "appletomatocabbage", it's not very useful, but I hope you get the point about `seq`)

The `'!'` quantifier is a `nott()` in disguise (like `'?'`, `'+'`, and `'*'` are `rep()` in disguise.

```javascript
  function paraline(i) {
    return seq('paraline', i, listli_head, '!', inline, eol); }

  // is equivalent to

  function not_listli_head(i) {
    return nott(null, i, listli_head); }
  function paraline(i) {
    return seq('paraline', i, not_listli_head, inline, eol); }
```


## "classes" (as in object class)

Basically, one only has to know about `Jaabro.Node`. It's the input to any `rewrite` method.

### Jaabro.Node

A jaabro result node.

```js
{
  name: 'exp',
  result: 1,
  input: someJaabroInput,
  offset: 0,
  length: 5,
  parter: 'seq',
  children: [
    // ...
  ]
}
```

This "class" understands the following methods:

* `toArray()`: returns an array representation of the node and its children
* `toString()`: returns a string representation of the node and its children
* `string()`: returns the string matched by the result node
* `strinp()`: returns the string matched by the result node, but trimmed
* `lookup(name)`: returns the first node with the given name (might return "this" node)
* `gather(name)`: returns all the nodes with the given name (starting with "this" node)

As seen above:
```js
  function rewrite_var(t) { return [ 'var', t.string().trim() ]; }
  function rewrite_number(t) { return [ 'num', t.string().trim() ]; }
    // or
  function rewrite_var(t) { return [ 'var', t.strinp() ]; }
  function rewrite_number(t) { return [ 'num', t.strinp() ]; }
```
The `t` is a `Jaabro.result`. The results for "var" and "num" named results get wrapped into some kind of s-expression with the result node string trimmed.


## providing a custom rewrite() function

As seen above, Jaabro provides a default implementation of `rewrite()` one that walks the parse tree and calls `rewrite_{node_name}(node)`. If one needs to completely bypass this default, providing a new `rewrite(node)` is OK.

```js
var MyParser = Jaabro.makeParser(function() {

  // parse

  // ...

  var root = thatParser;

  // rewrite

  function rewrite(t) {

    // follow some custom logic and return result...
  }
});
```

## testing the parser

The [saintmarc](https://github.com/jmettraux/saintmarc) markdown parser has a [test.html](https://github.com/jmettraux/saintmarc/blob/master/spec/test.html) that tests the parser directly in a browser and uses `Jaabro.Tree.toHtml()` to provide a browsable debug output tree.

It is very helpful to explore the parser in the early development stages. Then it's plain [specs](https://github.com/jmettraux/saintmarc/tree/master/spec).


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

