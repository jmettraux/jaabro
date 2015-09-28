
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
        return [ Jaabro.str('n0', i, 'world').toArray(), i.offset ];
      })).to eq(
        [ [ 'n0', 0, 0, 0, [] ], 0 ]
      )
    end

    it 'hits' do

      expect(js(%{
        var i = Jaabro.makeInput('world');
        return [ Jaabro.str('n0', i, 'world').toArray(), i.offset ];
      })).to eq(
        [ [ 'n0', 1, 0, 5, [] ], 5 ]
      )
    end
  end
end

