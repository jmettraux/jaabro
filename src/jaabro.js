
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
    return this.slice(this.offset, str_or_rex.length) === str_or_rex;
  }
  return false;
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
  if (input.match(str)) {
    r.result = 1;
    r.length = str.length;
    input.offset = input.offset + r.length;
  }

  return r;
};

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

  return this.root(this.makeInput(string));
};


//var MyParser = Object.create(Jaabro);
//MyParser.name = function(input) { return this.str(); };
//MyParser.root = function(input) { return JSON.stringify(input); };
  // or
//var MyParser = Jaabro.make({
//  root: function(input) { return JSON.stringify(input); }
//});

