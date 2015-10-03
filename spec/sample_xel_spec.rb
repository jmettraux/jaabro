
#
# specifying jaabro
#
# Tue Sep 29 17:55:50 JST 2015
#

require 'spec_helper'


XEL =
  %{
    var Xel = Jaabro.make(function() {

      //
      // parse

      function pa(i) { return str(null, i, '('); }
      function pz(i) { return str(null, i, ')'); }
      function com(i) { return str(null, i, ','); }

      function num(i) { return rex('num', i, /-?[0-9]+/); }

      function args(i) { return eseq('args', i, pa, exp, com, pz); }
      function funame(i) { return rex('funame', i, /[A-Z][A-Z0-9]*/); }
      function fun(i) { return seq('fun', i, funame, args); }

      function exp(i) { return alt('exp', i, fun, num); }

      var root = exp;

      //
      // rewrite

      function rewrite_num(t) { return parseInt(t.string(), 10); }

      function rewrite_fun(t) {
        var a = [];
        a.push(t.children[0].string());
        t.children[1].children.forEach(function(c) {
          if (c.name) a.push(rewrite(c));
        });
        return a;
      }

      function rewrite_exp(t) { return rewrite(t.children[0]); }
    });
  }


describe 'jaabro.js' do

  describe 'Xel' do

    describe '.parse' do

      it 'works' do

        expect(js(XEL + %{
          return Xel.parse('MUL(SUM(1,2),-3)');
        })).to eq(
          [ 'MUL', [ 'SUM', 1, 2 ], -3 ]
        )
      end

      it 'works (rewrite: false)' do

        expect(js(XEL + %{
          return Xel.parse('MUL(7,-3)', { rewrite: false }).toString();
        })).to eq(%{
1 "exp" 0,9
  1 "fun" 0,9
    1 "funame" 0,3 "MUL"
    1 "args" 3,6
      1 null 3,1 "("
      1 "exp" 4,1
        1 "num" 4,1 "7"
      1 null 5,1 ","
      1 "exp" 6,2
        1 "num" 6,2 "-3"
      1 null 8,1 ")"
        }.strip)
      end

      it 'returns null when it cannot parse' do

        expect(js(XEL + %{ return Xel.parse('MUL(7,-3') })).to eq(nil)
        expect(js(XEL + %{ return Xel.parse('MUL(7,-3) ') })).to eq(nil)
      end
    end
  end

  describe 'Jaabro.Result' do

    describe '.lookup(name)' do

      it 'returns null when it finds nothing' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.lookup('funk');
        })).to eq(
          nil
        )
      end

      it 'returns the first matching node (depth first)' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.children[0].lookup('exp').toString();
        })).to eq(%{
1 "exp" 4,1
  1 "num" 4,1 "7"
        }.strip)
      end
    end

    describe '.gather(name)' do

      it 'returns [] when it finds nothing'
      it 'returns all the matching nodes (depth first)'
    end
  end
end

