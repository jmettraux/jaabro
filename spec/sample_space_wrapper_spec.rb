
#
# specifying jaabro
#
# Mon Dec 14 08:44:59 JST 2015
#

require 'spec_helper'



describe 'jaabro.js' do

  describe 'SpaceWrapper' do

    describe '.parse' do

      it 'works' do

        expect(js(SPACE_WRAPPER + %{ return SpaceWrapper.parse('EXP'); })
          ).to eq('exp')
        expect(js(SPACE_WRAPPER + %{ return SpaceWrapper.parse(' EXP'); })
          ).to eq('exp')
      end

      it 'returns null when it cannot parse' do

        expect(js(SPACE_WRAPPER + %{ return SpaceWrapper.parse('EXP ') })
          ).to eq(nil)
        expect(js(SPACE_WRAPPER + %{ return SpaceWrapper.parse('MUL(7,-3) ') })
          ).to eq(nil)
      end
    end
  end
end

