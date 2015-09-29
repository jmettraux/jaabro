
#
# specifying jaabro
#
# Tue Sep 29 11:37:24 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'alt' do

    it 'misses' do

      expect(js(%{

        var i = Jaabro.makeInput('tutu');

        return [
          Jaabro.alt('n0', i, ta, to).toArray({ leaves: true }),
          i.offset
        ];
      })).to eq(
        [
          [ 'n0', 0, 0, 0, 'alt', [
            [ nil, 0, 0, 0, 'str', [] ],
            [ nil, 0, 0, 0, 'str', [] ]
          ] ],
          0
        ]
      )
    end

    it 'hits (1st hit)' do

      expect(js(%{

        var i = Jaabro.makeInput('tato');

        return [
          Jaabro.alt('n0', i, ta, to).toArray({ leaves: true }),
          i.offset
        ];
      })).to eq(
        [
          [ 'n0', 1, 0, 2, 'alt', [
            [ nil, 1, 0, 2, 'str', 'ta' ],
          ] ],
          2
        ]
      )
    end

    it 'hits (2nd hit)' do

      expect(js(%{

        var i = Jaabro.makeInput('tato');

        return [
          Jaabro.alt('n0', i, to, ta).toArray({ leaves: true }),
          i.offset
        ];
      })).to eq(
        [
          [ 'n0', 1, 0, 2, 'alt', [
            [ nil, 0, 0, 0, 'str', [] ],
            [ nil, 1, 0, 2, 'str', 'ta' ]
          ] ],
          2
        ]
      )
    end
  end
end

