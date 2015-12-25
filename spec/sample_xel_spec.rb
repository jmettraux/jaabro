
#
# specifying jaabro
#
# Tue Sep 29 17:55:50 JST 2015
#

require 'spec_helper'


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
    1 null 0,3 "MUL"
    1 null 3,6
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
end

