
#
# specifying jaabro
#
# Tue Sep 29 11:12:13 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'rex' do

    it 'misses' do

      expect(js(%{

        var i = Jaabro.makeInput('hello');

        return [ Jaabro.rex('n0', i, /lo/).toArray(), i.offset ];
      })).to eq(
        [ [ 'n0', 0, 0, 0, [] ], 0 ]
      )
    end

    it 'hits' do

      expect(js(%{

        var i = Jaabro.makeInput('world');

        return [ Jaabro.rex('n0', i, /worl?d/).toArray(), i.offset ];
      })).to eq(
        [ [ 'n0', 1, 0, 5, [] ], 5 ]
      )
    end

    it 'misses on an empty input' do

      expect(js(%{

        var i = Jaabro.makeInput('hello');
        i.offset = 5;

        return [ Jaabro.rex('n0', i, /hello/).toArray(), i.offset ];
      })).to eq(
        [ [ 'n0', 0, 5, 0, [] ], 5 ]
      )
    end
  end
end

