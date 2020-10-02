
#
# specifying jaabro
#
# Mon Dec 14 08:44:59 JST 2015
#

require 'spec_helper'



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

