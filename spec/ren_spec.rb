
#
# specifying jaabro
#
# Tue Sep 29 15:42:39 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'ren' do

    it 'renames the result of the wrapped parser' do

      expect(js(%{

        var i = Jaabro.makeInput('ta');
        var r = Jaabro.ren('reta', i, nta);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'reta', 1, 0, 2, 'str', 'ta' ],
          2
        ]
      )
    end
  end
end

