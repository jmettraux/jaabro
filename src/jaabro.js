
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
// Jaabro.Result

Jaabro.Result = {};

Jaabro.Result.prune = function() {

  var cn = []; this.children.forEach(function(c) {
    if (c.result === 1) cn.push(c);
  });
  this.children = cn;
};

Jaabro.Result.toArray = function(opts) {

  var cn = null;

  if (this.result === 1 && this.children.length === 0)
  {
    cn = this.input.slice(this.offset, this.length);
  }
  else {
    cn = []; for (var i = 0, l = this.children.length; i < l; i++) {
      cn.push(this.children[i].toArray(opts));
    }
  }

  return [
    this.name, this.result, this.offset, this.length, this.parter, cn ];
};

//
// Jaabro

Jaabro.str = function(name, input, str) {

  var r =
    this.makeResult(name, input, (typeof str) === 'string' ? 'str' : 'rex');

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

  var r = this.makeResult(name, input, 'alt');
  var cr = null;

  for (var i = 2, l = arguments.length; i < l; i++) {
    cr = arguments[i](input);
    r.children.push(cr);
    if (cr.result === 1) break;
  }

  if (cr && cr.result == 1) {
    r.result = 1;
    r.length = cr.length;
  }

  return r;
};

Jaabro.qmark = function() { return [ 0, 1 ]; };
Jaabro.star = function() { return [ 0, 0 ]; };
Jaabro.plus = function() { return [ 1, 0 ]; };

Jaabro._quantify = function(parser) {

  if (parser === this.qmark) return parser();
  if (parser === this.star) return parser();
  if (parser === this.plus) return parser();
  return false;
};

Jaabro.seq = function(name, input, parsers_) {

  var o = input.offset;
  var r = this.makeResult(name, input, 'seq');
  var cr = null;

  var ps = []; for (var i = 2, l = arguments.length; i < l; i++) {
    ps.push(arguments[i]);
  }
  while (true) {
    var p = ps.shift(); if ( ! p) break;
    cr = p(input);
    r.children.push(cr);
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

//    def rep(name, input, parser, min, max=0)
//
//      min = 0 if min == nil || min < 0
//      max = nil if max.nil? || max < 1
//
//      r = ::Raabro::Tree.new(name, :rep, input)
//      start = input.offset
//      count = 0
//
//      loop do
//        c = _parse(parser, input)
//        r.children << c
//        break if c.result != 1
//        count += 1
//        break if max && count == max
//      end
//
//      if count >= min && (max == nil || count <= max)
//        r.result = 1
//        r.length = input.offset - start
//      else
//        input.offset = start
//      end
//
//      r.prune! if input.options[:prune]
//
//      r
//    end
Jaabro.rep = function(name, input, parser, min, max) {

  if (min === null || min === undefined || min < 0) min = 0;
  if (max === null || max === undefined || max < 0) max = 0;

  var o = input.offset;
  var r = this.makeResult(name, input, 'rep');
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

Jaabro.make = function(object) {

  var o = Object.create(Jaabro);
  for (var k in object) o[k] = object[k];

  return o;
};
Jaabro.makeParser = Jaabro.make;

Jaabro.makeInput = function(string, opts) {

  var i = Object.create(Jaabro.Input);
  i.string = string;
  i.offset = 0;
  i.options = opts || {};

  return i;
};

Jaabro.makeResult = function(name, input, parter) {

  var r = Object.create(Jaabro.Result);
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

  // TODO opts

  return this.root(this.makeInput(string));
};

