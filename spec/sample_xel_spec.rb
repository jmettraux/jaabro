
#
# specifying jaabro
#
# Tue Sep 29 17:55:50 JST 2015
#

require 'spec_helper'


#module Sample::Xel include Raabro
#
#  # parse
#
#  # ...
#
#  # rewrite
#
#  def rewrite_exp(t); rewrite(t.children[0]); end
#  def rewrite_num(t); t.string.to_i; end
#
#  def rewrite_fun(t)
#    [ t.children[0].string ] +
#    t.children[1].children.inject([]) { |a, e| a << rewrite(e) if e.name; a }
#  end
#end
XEL =
  %{
    var Xel = Jaabro.make({

      pa: function(i) { return this.str(nil, i, '('); },
      pz: function(i) { return this.str(nil, i, ')'); },
      com: function(i) { return this.str(nil, i, ','); },

      num: function(i) { return this.rex('num', i, /-?[0-9]+/); },

      args: function(i) { return this.eseq('args', i, pa, exp, com, pz); },
      funame: function(i) { return this.rex('funame', i, /[A-Z][A-Z0-9]*/); },
      fun: function(i) { return this.seq('fun', i, funame, args); },

      exp: function(i) { return this.alt('exp', i, fun, num); },

      //root: this.exp
    });
    Xel.root = Xel.exp;
  }


describe 'jaabro.js' do

  describe 'Xel' do

    describe '.parse' do

      it 'works'

      it 'works (rewrite: false)' do

        expect(js(XEL + %{
          return Xel.parse('MUL(7,-3)', { rewrite: false });
        })).to eq(
          :x
        )
      end
    end
  end
#    describe '.funame' do
#
#      it 'hits' do
#
#        i = Raabro::Input.new('NADA')
#
#        t = Sample::Xel.funame(i)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ :funame, 1, 0, 4, nil, :rex, 'NADA' ]
#        )
#      end
#    end
#
#    describe '.fun' do
#
#      it 'parses a function call' do
#
#        i = Raabro::Input.new('SUM(1,MUL(4,5))', :prune => true)
#
#        t = Sample::Xel.fun(i)
#
#        expect(t.result).to eq(1)
#
#        expect(
#          Sample::Xel.rewrite(t)
#        ).to eq(
#          [ 'SUM', 1, [ 'MUL', 4, 5 ] ]
#        )
#      end
#    end
#
#    describe '.parse' do
#
#      it 'parses (success)' do
#
#        expect(
#          Sample::Xel.parse('MUL(7,-3)')
#        ).to eq(
#          [ 'MUL', 7, -3 ]
#        )
#      end
#
#      it 'parses (rewrite: false, success)' do
#
#        expect(
#          Sample::Xel.parse('MUL(7,-3)', rewrite: false).to_s
#        ).to eq(%{
#1 :exp 0,9
#  1 :fun 0,9
#    1 :funame 0,3 "MUL"
#    1 :args 3,6
#      1 nil 3,1 "("
#      1 :exp 4,1
#        1 :num 4,1 "7"
#      1 nil 5,1 ","
#      1 :exp 6,2
#        1 :num 6,2 "-3"
#      1 nil 8,1 ")"
#        }.strip)
#      end
#
#      it 'parses (miss)' do
#
#        expect(Sample::Xel.parse('MUL(7,3) ')).to eq(nil)
#        expect(Sample::Xel.parse('MUL(7,3')).to eq(nil)
#      end
#    end
#  end
end

