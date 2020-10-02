
#
# specifying jaabro
#
# Tue Sep 29 16:47:30 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'eseq' do

    it 'hits' do

      expect(js(%{

        var i = Jaabro.makeInput('<a,b>');
        var r = Jaabro.eseq('es', i, lt, cha, com, gt);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'es', 1, 0, 5, 'eseq', [
            [ nil, 1, 0, 1, 'str', '<' ],
            [ nil, 1, 1, 1, 'rex', 'a' ],
            [ nil, 1, 2, 1, 'str', ',' ],
            [ nil, 1, 3, 1, 'rex', 'b' ],
            [ nil, 0, 4, 0, 'str', [] ],
            [ nil, 1, 4, 1, 'str', '>' ]
          ] ],
          5
        ]
      )
    end

    it 'prunes' do

      expect(js(%{

        var i = Jaabro.makeInput('<a,b>', { prune: true });
        var r = Jaabro.eseq('es', i, lt, cha, com, gt);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'es', 1, 0, 5, 'eseq', [
            [ nil, 1, 0, 1, 'str', '<' ],
            [ nil, 1, 1, 1, 'rex', 'a' ],
            [ nil, 1, 2, 1, 'str', ',' ],
            [ nil, 1, 3, 1, 'rex', 'b' ],
            [ nil, 1, 4, 1, 'str', '>' ]
          ] ],
          5
        ]
      )
    end

    it 'hits even when empty' do

      expect(js(%{

        var i = Jaabro.makeInput('<>');
        var r = Jaabro.eseq('es', i, lt, cha, com, gt);

        return [ r.toArray({ leaves: true }), i.offset ];
      })).to eq(
        [
          [ 'es', 1, 0, 2, 'eseq', [
            [ nil, 1, 0, 1, 'str', '<' ],
            [ nil, 0, 1, 0, 'rex', [] ],
            [ nil, 1, 1, 1, 'str', '>' ],
          ] ],
          2
        ]
      )
    end

    context 'no start parser' do

      it 'hits' do

        expect(js(%{

          var i = Jaabro.makeInput('a,b>');
          var r = Jaabro.eseq('es', i, null, cha, com, gt);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'es', 1, 0, 4, 'eseq', [
              [ nil, 1, 0, 1, 'rex', 'a' ],
              [ nil, 1, 1, 1, 'str', ',' ],
              [ nil, 1, 2, 1, 'rex', 'b' ],
              [ nil, 0, 3, 0, 'str', [] ],
              [ nil, 1, 3, 1, 'str', '>' ]
            ] ],
            4
          ]
        )
      end
    end

    context 'no end parser' do

      it 'hits' do

        expect(js(%{

          var i = Jaabro.makeInput('<a,b');
          var r = Jaabro.eseq('es', i, lt, cha, com, null);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'es', 1, 0, 4, 'eseq', [
              [ nil, 1, 0, 1, 'str', '<' ],
              [ nil, 1, 1, 1, 'rex', 'a' ],
              [ nil, 1, 2, 1, 'str', ',' ],
              [ nil, 1, 3, 1, 'rex', 'b' ],
              [ nil, 0, 4, 0, 'str', [] ]
            ] ],
            4
          ]
        )
      end

      it 'prunes' do

        expect(js(%{

          var i = Jaabro.makeInput('<a,b', { prune: true });
          var r = Jaabro.eseq('es', i, lt, cha, com, null);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'es', 1, 0, 4, 'eseq', [
              [ nil, 1, 0, 1, 'str', '<' ],
              [ nil, 1, 1, 1, 'rex', 'a' ],
              [ nil, 1, 2, 1, 'str', ',' ],
              [ nil, 1, 3, 1, 'rex', 'b' ]
            ] ],
            4
          ]
        )
      end
    end
  end
end

