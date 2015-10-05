
//
// Copyright (c) 2015-2015, John Mettraux, jmettraux@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

var Jaabro = { VERSION: '1.0.0' };

//
// Jaabro.Input

Jaabro.Input = {};

Jaabro.Input.slice = function(offset, length) {

  if (offset === undefined || offset === null) offset = this.offset;
  if (length === undefined) return this.string.slice(offset);
  return this.string.slice(offset, offset + length);
};

Jaabro.Input.match = function(str_or_rex) {

  if ((typeof str_or_rex) === 'string') {
    var l = str_or_rex.length;
    return this.slice(this.offset, l) === str_or_rex ? l : -1;
  }

  var m = this.slice(this.offset).match(str_or_rex);
  return m !== null && m.index == 0 ? m[0].length : -1;
};

//
// Jaabro.Node

Jaabro.Node = {};

Jaabro.Node.prune = function() {

  var cn = []; this.children.forEach(function(c) {
    if (c.result === 1) cn.push(c);
  });
  this.children = cn;
};

Jaabro.Node.string = function() {

  return this.input.slice(this.offset, this.length);
};

Jaabro.Node.lookup = function(name) {

  if (this.name === name) return this;

  for (var i = 0, l = this.children.length; i < l; i++) {
    var r = this.children[i].lookup(name);
    if (r) return r;
  }
  return null;
};

Jaabro.Node.gather = function(name) {

  var acc = arguments[1] || [];

  if (this.name === name)
    acc.push(this);
  else
    this.children.forEach(function(c) { c.gather(name, acc) });

  return acc;
};

Jaabro.Node.toArray = function(opts) {

  var cn = null;

  if (this.result === 1 && this.children.length === 0)
  {
    cn = this.string();
  }
  else {
    cn = []; for (var i = 0, l = this.children.length; i < l; i++) {
      cn.push(this.children[i].toArray(opts));
    }
  }

  return [
    this.name, this.result, this.offset, this.length, this.parter, cn ];
};

Jaabro.Node.toString = function() {

  var depth = arguments[0] || 0;
  var string = arguments[1] || [];

  if (depth > 0) string.push('\n');
  for (var i = 0; i < depth; i++) string.push('  ');

  string.push(this.result, ' ', JSON.stringify(this.name), ' ');
  string.push(this.offset, ',', this.length);

  if (this.result === 1 && this.children.length === 0) {
    string.push(' ', JSON.stringify(this.string()));
  }

  this.children.forEach(function(c) { c.toString(depth + 1, string); });

  return depth == 0 ? string.join('') : null;
};

//
// Jaabro

Jaabro.str = function(name, input, str) {

  var r =
    this.makeNode(name, input, (typeof str) === 'string' ? 'str' : 'rex');

  var l = input.match(str);
  if (l > -1) {
    r.result = 1;
    r.length = l;
    input.offset = input.offset + l;
  }

  return r;
};
Jaabro.rex = Jaabro.str;

Jaabro.alt = function(name, input, parsers_) {

  var ps = [];
  for (var i = 2, l = arguments.length; i < l; i++) ps.push(arguments[i]);

  // greedy ?
  var l = ps[ps.length - 1];
  var g = false; if (l === true || l === false) { ps.pop(); g = l; }

  var o = input.offset;
  var r = this.makeNode(name, input, g ? 'altg' : 'alt');
  var cr = null;

  while (true) {

    var p = ps.shift(); if ( ! p) break;

    var rr = p(input);
    r.children.push(rr);

    input.offset = o;

    if (g) {
      if (rr.result === 1 && rr.length > (cr ? cr.length : -1)) {
        if (cr) cr.result = 0;
        cr = rr;
      }
    }
    else {
      cr = rr;
      if (rr.result === 1) break;
    }
  };

  if (cr && cr.result === 1) {
    r.result = 1;
    r.length = cr.length;
    input.offset = o + r.length;
  }

  if (input.options.prune) r.prune();

  return r;
};

Jaabro.altg = function(name, input, parsers_) {

  var as = [];
  for (var i = 0, l = arguments.length; i < l; i++) as.push(arguments[i]);
  as.push(true);

  return this.alt.apply(this, as);
};

Jaabro.qmark = function() { return [ 0, 1 ]; };
Jaabro.star = function() { return [ 0, 0 ]; };
Jaabro.plus = function() { return [ 1, 0 ]; };
Jaabro.qmark.jname = 'qmark';
Jaabro.qmark.quantifier = true;
Jaabro.star.jname = 'star';
Jaabro.star.quantifier = true;
Jaabro.plus.jname = 'plus';
Jaabro.plus.quantifier = true;

Jaabro.toQuantifier = function(parser) {

  if (parser === '?') return this.qmark;
  if (parser === '*') return this.star;
  if (parser === '+') return this.plus;
  if (parser && parser.quantifier) return parser;
  return null;
};

Jaabro.quantify = function(parser) {

  var q = this.toQuantifier(parser);
  return q ? q() : false;
};

Jaabro.seq = function(name, input, parsers_) {

  var o = input.offset;
  var r = this.makeNode(name, input, 'seq');
  var cr = null;

  var ps = []; for (var i = 2, l = arguments.length; i < l; i++) {
    ps.push(arguments[i]);
  }

  while (true) {

    var p = ps.shift(); if ( ! p) break;
    if (this.toQuantifier(p)) throw new Error('lonely quantifier ' + p.jname);

    var q = this.quantify(ps[0]);

    if (q) {
      ps.shift();
      cr = this.rep(null, input, p, q[0], q[1]);
      r.children = r.children.concat(cr.children);
    }
    else {
      cr = p(input);
      r.children.push(cr);
    }

    if (cr.result !== 1) break;
  }

  if (cr.result === 1) {
    r.result = 1;
    r.length = input.offset - o;
  }
  else {
    input.offset = o;
  }

  return r;
};

Jaabro.rep = function(name, input, parser, min, max) {

  if (min === null || min === undefined || min < 0) min = 0;
  if (max === null || max === undefined || max < 0) max = 0;

  var o = input.offset;
  var r = this.makeNode(name, input, 'rep');
  var count = 0;

  while (true) {
    var cr = parser(input);
    r.children.push(cr);
    if (cr.result !== 1) break;
    count = count + 1;
    if (max > 0 && count === max) break;
  }

  if (count >= min && (max < 1 || count <= max)) {
    r.result = 1;
    r.length = input.offset - o;
  }
  else {
    input.offset = o;
  }

  if (input.options.prune) r.prune();

  return r;
};

Jaabro.ren = function(name, input, parser) {

  var cr = parser(input);
  cr.name = name;

  return cr;
};

Jaabro.all = function(name, input, parser) {

  var o = input.offset;
  var l = input.string.length - o;
  var r = this.makeNode(name, input, 'all');

  var cr = parser(input);
  r.children.push(cr);

  if (cr.length < l) { input.offset = o; }
  else { r.result = 1; r.length = l; }

  return r;
};

Jaabro.eseq = function(name, input, startp, eltp, sepp, endp) {

  var j = false; // jseq?

  if (sepp === undefined && endp === undefined) {
    j = true;
    sepp = eltp; eltp = startp; startp = null;
  }

  var o = input.offset;
  var r = this.makeNode(name, input, j ? 'jseq' : 'eseq');
  r.result = 1;
  var cr = null;

  if (startp) {
    cr = startp(input);
    r.children.push(cr);
    if (cr.result !== 1) r.result = 0;
  }

  if (r.result === 1) {

    var i = 1;
    var count = 0;

    while (true) {

      i = (i + 1) % 2;
      var p = i == 0 ? eltp : sepp;

      cr = p(input);
      r.children.push(cr);

      if (cr.result !== 1) break;

      count = count + 1;
    }

    if (j && count < 1) r.result = 0;
  }

  if (r.result === 1 && endp) {
    cr = endp(input);
    r.children.push(cr);
    if (cr.result !== 1) r.result = 0;
  }

  if (r.result == 1) r.length = input.offset - o;
  else input.offset = o;

  if (input.options.prune) r.prune();

  return r;
};
Jaabro.jseq = Jaabro.eseq;

Jaabro.make = function(fun) {

  var p = Object.create(Jaabro);

  var funs = fun.toString();
  'all alt altg eseq jseq ren rep rex seq str'.split(' ').forEach(function(f) {
    funs = funs.replace(
      new RegExp(" +" + f + "\\(", 'g'),
      ' Jaabro.' + f + '(');
  });
  funs =
    funs.slice(0, funs.lastIndexOf('}')) +
    'var rewrite;' +
    'rewrite= ' +
      'rewrite ||' +
      'function(t) { return eval("rewrite_" + t.name)(t); };' +
    'try { eval("root"); } catch(err) {' +
      'throw new Error("missing function root() parser");' +
    '};' +
    'return [ root, rewrite ];' +
    '}';
  //print(">>>" + funs + "<<<");

  //eval('fun = ' + funs);
  fun = eval('(' + funs + ')');

  //var rw = fun.call(p, p);
  var rw = fun(p); // pass the parser, could be useful
  p.root = rw[0];
  p.rewrite = rw[1];

  return p;
};
Jaabro.makeParser = Jaabro.make;

Jaabro.makeInput = function(string, opts) {

  var i = Object.create(Jaabro.Input);
  i.string = string;
  i.offset = 0;
  i.options = opts || {};

  return i;
};

Jaabro.makeNode = function(name, input, parter) {

  var r = Object.create(Jaabro.Node);
  r.name = name;
  r.result = 0;
  r.input = input;
  r.offset = input.offset;
  r.length = 0;
  r.parter = parter;
  r.children = [];

  return r;
};

Jaabro.parse = function(string, opts) {

  opts = opts || {};

  d = parseInt(opts.debug, 10) || 0
  if (d > 0) opts.rewrite = false;
  if (d > 1) opts.all = false;
  if (d > 2) opts.prune = false;

  if ( ! opts.hasOwnProperty('prune')) opts.prune = true;

  var t = null;
  if (opts.all === false) t = this.root(this.makeInput(string, opts));
  else t = Jaabro.all(null, this.makeInput(string, opts), this.root);

  if (opts.prune != false && t.result !== 1) return null;

  if (t.parter === 'all') t = t.children[0];

  if (opts.rewrite !== false) return this.rewrite(t);

  return t;
};

