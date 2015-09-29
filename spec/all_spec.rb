
#
# specifying jaabro
#
# Tue Sep 29 15:50:01 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'all' do

    it 'fails when not all the input is consumed' do

      expect(js(%{

        var i = Jaabro.makeInput('tototota');
        var r = Jaabro.all(null, i, to_plus);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ nil, 0, 0, 0, 'all', [
            [ 'tos', 1, 0, 6, 'rep', [
              [ nil, 1, 0, 2, 'str', 'to' ],
              [ nil, 1, 2, 2, 'str', 'to' ],
              [ nil, 1, 4, 2, 'str', 'to' ],
              [ nil, 0, 6, 0, 'str', [] ]
            ] ]
          ] ],
          0
        ]
      )
    end

    it 'succeeds when all the input is consumed' do

      expect(js(%{

        var i = Jaabro.makeInput('tototo');
        var r = Jaabro.all(null, i, to_plus);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ nil, 1, 0, 6, 'all', [
            [ 'tos', 1, 0, 6, 'rep', [
              [ nil, 1, 0, 2, 'str', 'to' ],
              [ nil, 1, 2, 2, 'str', 'to' ],
              [ nil, 1, 4, 2, 'str', 'to' ],
              [ nil, 0, 6, 0, 'str', [] ]
            ] ]
          ] ],
          6
        ]
      )
    end
  end
end

