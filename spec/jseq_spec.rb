
#
# specifying jaabro
#
# Tue Sep 29 16:12:15 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'jseq' do

    it 'parses elts joined by a separator' do

      expect(js(%{

        var i = Jaabro.makeInput('a,b,c');
        var r = Jaabro.jseq('j', i, cha, com);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'j', 1, 0, 5, 'jseq', [
            [ nil, 1, 0, 1, 'rex', 'a' ],
            [ nil, 1, 1, 1, 'str', ',' ],
            [ nil, 1, 2, 1, 'rex', 'b' ],
            [ nil, 1, 3, 1, 'str', ',' ],
            [ nil, 1, 4, 1, 'rex', 'c' ],
            [ nil, 0, 5, 0, 'str', [] ]
          ] ],
          5
        ]
      )
    end

    it 'prunes' do

      expect(js(%{

        var i = Jaabro.makeInput('a,b,c', { prune: true });
        var r = Jaabro.jseq('j', i, cha, com);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'j', 1, 0, 5, 'jseq', [
            [ nil, 1, 0, 1, 'rex', 'a' ],
            [ nil, 1, 1, 1, 'str', ',' ],
            [ nil, 1, 2, 1, 'rex', 'b' ],
            [ nil, 1, 3, 1, 'str', ',' ],
            [ nil, 1, 4, 1, 'rex', 'c' ]
          ] ],
          5
        ]
      )
    end

    it 'fails when 0 elements' do

      expect(js(%{

        var i = Jaabro.makeInput('');
        var r = Jaabro.jseq('j', i, cha, com);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'j', 0, 0, 0, 'jseq', [
            [ nil, 0, 0, 0, 'rex', [] ],
          ] ],
          0
        ]
      )
    end

    it 'refuses trailing separators' do

      expect(js(%{

        var i = Jaabro.makeInput('a,b,');
        var r = Jaabro.jseq('j', i, cha, com);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          ["j", 0, 0, 0, "jseq", [
            [nil, 1, 0, 1, "rex", "a"],
            [nil, 1, 1, 1, "str", ","],
            [nil, 1, 2, 1, "rex", "b"],
            [nil, 1, 3, 1, "str", ","],
            [nil, 0, 4, 0, "rex", []]]],
          0
        ]
      )
    end
  end
end

