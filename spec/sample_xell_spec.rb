
#
# specifying jaabro
#
# Mon Dec 14 08:44:59 JST 2015
#

require 'spec_helper'


XELL =
  %{
    var Xell = Jaabro.make(function() {

      //
      // parse

      function pa(i) { return rex(null, i, /\\(\\s*/); }
      function pz(i) { return rex(null, i, /\\s*\\)/); }
      function com(i) { return str(null, i, ','); }

      function num(i) { return rex('num', i, /\\s*-?[0-9]+\\s*/); }

      function args(i) { return eseq(null, i, pa, exp, com, pz); }
      function funame(i) { return rex(null, i, /[A-Z][A-Z0-9]*/); }
      function fun(i) { return seq('fun', i, funame, args); }

      function exp(i) { return alt(null, i, fun, num); }

      var root = exp;

      //
      // rewrite

      function rewrite_num(t) {
        return parseInt(t.string(), 10);
      }

      function rewrite_fun(t) {
        var a = [];
        a.push(t.children[0].string());
        t.children[1].oddChildren().forEach(
          function(c) { a.push(rewrite(c)); });
        return a;
      }
    });
  }


describe 'jaabro.js' do

  describe 'Xell' do

    describe '.parse' do

      it 'works' do

        expect(js(XELL + %{
          return Xell.parse('MUL(SUM(1,2),-3)');
        })).to eq(
          [ 'MUL', [ 'SUM', 1, 2 ], -3 ]
        )
      end

      it 'returns null when it cannot parse' do

        expect(js(XELL + %{ return Xell.parse('MUL(7,-3') })).to eq(nil)
        expect(js(XELL + %{ return Xell.parse('MUL(7,-3) ') })).to eq(nil)
      end
    end
  end
end

