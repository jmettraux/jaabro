
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

var Jaabro = {};

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

Jaabro.Result.toArray = function(opts) {

  // TODO opts

  var cn = []; for (var i = 0, l = this.children.length; i < l; i++) {
    cn.push(this.children[i].toArray(opts));
  }

  return [ this.name, this.result, this.offset, this.length, cn ];
};

//
// Jaabro

Jaabro.str = function(name, input, str) {

  var r = this.makeResult(name, input);
  var l = input.match(str);
  if (l > -1) {
    r.result = 1;
    r.length = l;
    input.offset = input.offset + l;
  }

  return r;
};
Jaabro.rex = Jaabro.str;

Jaabro.make = function(object) {

  var o = Object.create(Jaabro);
  for (var k in object) o[k] = object[k];

  return o;
};

Jaabro.makeInput = function(string) {

  var i = Object.create(Jaabro.Input);
  i.string = string;
  i.offset = 0;

  return i;
};

Jaabro.makeResult = function(name, input) {

  var r = Object.create(Jaabro.Result);
  r.name = name;
  r.result = 0;
  r.input = input;
  r.offset = input.offset;
  r.length = 0;
  r.children = [];

  return r;
};

Jaabro.parse = function(string, opts) {

  // TODO opts

  return this.root(this.makeInput(string));
};

