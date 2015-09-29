
#
# specifying jaabro
#
# Tue Sep 29 13:30:04 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'seq' do

    it 'misses' do

      expect(js(%{

        var i = Jaabro.makeInput('tato');

        return [
          Jaabro.seq('n0', i, to, ta).toArray({ leaves: true }),
          i.offset
        ];
      })).to eq(
        [
          [ 'n0', 0, 0, 0, 'seq', [
            [ nil, 0, 0, 0, 'str', [] ]
          ] ],
          0
        ]
      )
    end

    it 'hits' do

      expect(js(%{

        var i = Jaabro.makeInput('tato');

        return [
          Jaabro.seq('n0', i, ta, to).toArray({ leaves: true }),
          i.offset
        ];
      })).to eq(
        [
          [ 'n0', 1, 0, 4, 'seq', [
            [ nil, 1, 0, 2, 'str', 'ta' ],
            [ nil, 1, 2, 2, 'str', 'to' ]
          ] ],
          4
        ]
      )
    end
  end

  describe 'seq and quantifiers' do

    describe 'a lonely quantifier' do

      it 'throws an error' do

        expect {
          js(%{
            var i = Jaabro.makeInput('something');
            return Jaabro.seq('n0', i, Jaabro.qmark);
          })
        }.to raise_error(ExecJS::ProgramError, 'Error: lonely quantifier qmark')
      end
    end

    describe 'the question mark quantifier' do

      it 'lets optional elements appear in sequences (miss)'
      it 'lets optional elements appear in sequences (hit)'
      it 'lets optional elements appear in sequences (fail)'
    end

    describe 'the star quantifier' do

      it 'lets optional elements recur in sequences (hit zero)'
      it 'lets optional elements recur in sequences (hit)'
    end

    describe 'the plus quantifier' do

      it 'lets elements recur in sequences (hit)'
      it 'lets elements recur in sequences (fail)'
    end
  end
end

