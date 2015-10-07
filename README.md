
# jaabro

A very dumb PEG parser library.

Brother to [raabro](https://github.com/jmettraux/raabro), son to [aabro](https://github.com/flon-io/aabro), grandson to [neg](https://github.com/jmettraux/neg), grand-grandson to [parslet](https://github.com/kschiess/parslet).


## a sample parser

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
      mod = { '-': 'opp', '/': 'inv' }[c.string().trim()];
    }

    return a;
  }
  var rewrite_mul = rewrite_add;

  function rewrite_fun(t) {

    var a = [ t.children[0].string() ];
    t.children[1].children.forEach(function(c) {
      if (c.name) a.push(rewrite(c));
    });

    return a;
  }

  function rewrite_exp(t) { return rewrite(t.children[0]); }

  function rewrite_par(t) { return rewrite(t.children[1]); }

  function rewrite_var(t) { return [ 'var', t.string().trim() ]; }
  function rewrite_number(t) { return [ 'num', t.string().trim() ]; }

  function rewrite_string(t) {

    var s = t.children[0].string().trim();
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
["SUM",["num","10"],["IF",["cmp","=",["var","c10"],["str","yes"]],["num","11"],["num","0"]]]
```

The [raabro README](https://github.com/jmettraux/raabro#readme) will help.


## "classes"

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
* `lookup(name)`: returns the first node with the given name (might return "this" node)
* `gather(name)`: returns all the nodes with the given name (starting with "this" node)

As seen above:
```js
  function rewrite_var(t) { return [ 'var', t.string().trim() ]; }
  function rewrite_number(t) { return [ 'num', t.string().trim() ]; }
```
The `t` is a `Jaabro.result`. The results for "var" and "num" named results get wrapped into some kind of s-expression with the result node string trimmed.


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

