
#
# specifying jaabro
#
# Mon Sep 28 21:08:18 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'str' do

    it 'misses' do

      expect(js(%{

        var i = Jaabro.makeInput('hello');

        return [
          Jaabro.str('n0', i, 'world').toArray({ leaves: true }),
          i.offset ];
      })).to eq(
        [ [ 'n0', 0, 0, 0, 'str', [] ], 0 ]
      )
    end

    it 'hits' do

      expect(js(%{

        var i = Jaabro.makeInput('world');

        return [
          Jaabro.str('n0', i, 'world').toArray({ leaves: true }),
          i.offset ];
      })).to eq(
        [ [ 'n0', 1, 0, 5, 'str', 'world' ], 5 ]
      )
    end

    it 'hits just enough' do

      expect(js(%{

        var i = Jaabro.makeInput('world');

        return [
          Jaabro.str('n0', i, 'wo').toArray({ leaves: true }),
          i.offset ];
      })).to eq(
        [ [ 'n0', 1, 0, 2, 'str', 'wo' ], 2 ]
      )
    end

    it 'misses on an empty input' do

      expect(js(%{

        var i = Jaabro.makeInput('hello');
        i.offset = 5;

        return [
          Jaabro.str('n0', i, 'world').toArray({ leaves: true }),
          i.offset ];
      })).to eq(
        [ [ 'n0', 0, 5, 0, 'str', [] ], 5 ]
      )
    end
  end
end

