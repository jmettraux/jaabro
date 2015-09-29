
#
# specifying jaabro
#
# Tue Sep 29 14:17:22 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'rep' do

    it 'misses (min not reached)' do

      expect(js(%{

        var i = Jaabro.makeInput('toto');
        var r = Jaabro.rep('n0', i, to, 3, 4);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'n0', 0, 0, 0, 'rep', [
            [ nil, 1, 0, 2, 'str', 'to' ],
            [ nil, 1, 2, 2, 'str', 'to' ],
            [ nil, 0, 4, 0, 'str', [] ]
          ] ],
          0
        ]
      )
    end

    it 'hits' do

      expect(js(%{

        var i = Jaabro.makeInput('toto');
        var r = Jaabro.rep('n0', i, to, 2, 2);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'n0', 1, 0, 4, 'rep', [
            [ nil, 1, 0, 2, 'str', 'to' ],
            [ nil, 1, 2, 2, 'str', 'to' ]
          ] ],
          4
        ]
      )
    end

    it 'prunes' do

      expect(js(%{

        var i = Jaabro.makeInput('toto', { prune: true });
        var r = Jaabro.rep('n0', i, to, 3, 4);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'n0', 0, 0, 0, 'rep', [
            [ nil, 1, 0, 2, 'str', 'to' ],
            [ nil, 1, 2, 2, 'str', 'to' ]
          ] ],
          0
        ]
      )
    end

    it 'hits (max set)' do

      expect(js(%{

        var i = Jaabro.makeInput('tototo');
        var r = Jaabro.rep('n0', i, to, 1, 2);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'n0', 1, 0, 4, 'rep', [
            [ nil, 1, 0, 2, 'str', 'to' ],
            [ nil, 1, 2, 2, 'str', 'to' ]
          ] ],
          4
        ]
      )
    end

    it 'hits (max not set)' do

      expect(js(%{

        var i = Jaabro.makeInput('toto');
        var r = Jaabro.rep('n0', i, to, 1);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'n0', 1, 0, 4, 'rep', [
            [ nil, 1, 0, 2, 'str', 'to' ],
            [ nil, 1, 2, 2, 'str', 'to' ],
            [ nil, 0, 4, 0, 'str', [] ]
          ] ],
          4
        ]
      )
    end
  end
end

