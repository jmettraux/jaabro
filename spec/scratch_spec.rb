
#
# specifying jaabro
#
# Tue Sep 29 06:50:39 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  it 'works' do

    expect(js(%{

      //var MyParser = Jaabro.make({
      //  root: function(input) { return this.str("title", input, "title"); }
      //});
      //return MyParser.parse("title");

      //var Car = {};
      //Car.getKm = function() { return 1000; };
      //var makeCar = function(f) {
      //  var c = Object.create(Car);
      //  if (f) {
      //    //var r = f.call({});
      //    var r = f();
      //    for (var k in r) c[k] = r[k];
      //  }
      //  return c;
      //};
      //var c = makeCar(function() {
      //  var make = "Mazda";
      //  this.getMake = function() { return make + this.getKm(); };
      //  return this;
      //});
      //return [ c.getKm(), c.getMake() ];

      var MyParser = Jaabro.make(function() {

        function hello(i) { return rex('h', i, /hello */); }
        function world(i) { return str('w', i, 'world'); }
        function root(i) { return seq('hw', i, hello, world); }

        function rewrite_xxx(t) { return 'y'; }
      });
      //return MyParser.rewrite({ name: 'xxx' });
      return MyParser.parse('hello', { debug: 3 }).toArray();
    })).to eq(
      [ 'hw', 0, 0, 0, 'seq', [
        [ 'h', 1, 0, 5, 'rex', 'hello' ],
        [ 'w', 0, 5, 0, 'str', [] ]
      ] ]
    )
  end
end

