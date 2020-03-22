
#
# specifying jaabro
#
# Mon Mar 23 06:27:43 JST 2020
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'nott' do

    it 'hits' do

      r = js %{

        var i = Jaabro.makeInput('to');
        var r = Jaabro.nott('no0', i, ta);

        return [ r.toArray({ leaves: true }), i.offset ];
      }

      expect(r).to eq([
        [ 'no0', 1, 0, 0, 'nott', [
          [ nil, 0, 0, 0, 'str', [] ] ] ],
        0 ])
    end

    it 'misses' do

      r = js %{

        var i = Jaabro.makeInput('ta');
        var r = Jaabro.nott('no0', i, ta);

        return [ r.toArray({ leaves: true }), i.offset ];
      }

      expect(r).to eq([
        [ 'no0', 0, 0, 0, 'nott', [
          [ nil, 1, 0, 2, 'str', 'ta' ] ] ],
        0 ])
    end
  end
end

