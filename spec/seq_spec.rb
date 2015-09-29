
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

      it 'lets optional elements appear in sequences (miss)' do

        expect(js(%{

          var i = Jaabro.makeInput('tato');
          var r = Jaabro.seq('n0', i, ta, tu, '?', to);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'n0', 1, 0, 4, 'seq', [
              [ nil, 1, 0, 2, 'str', 'ta' ],
              [ nil, 0, 2, 0, 'str', [] ],
              [ nil, 1, 2, 2, 'str', 'to' ]
            ] ],
            4
          ]
        )
      end

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

#    describe 'the question mark quantifier' do
#
#      it 'lets optional elements appear in sequences (hit)' do
#
#        i = Raabro::Input.new('tatuto')
#
#        t = Raabro.seq(nil, i, :ta, :tu, '?', :to)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 1, 0, 6, nil, :seq, [
#            [ nil, 1, 0, 2, nil, :str, 'ta' ],
#            [ nil, 1, 2, 2, nil, :str, 'tu' ],
#            [ nil, 1, 4, 2, nil, :str, 'to' ]
#          ] ]
#        )
#        expect(i.offset).to eq(6)
#      end
#
#      it 'lets optional elements appear in sequences (fail)' do
#
#        i = Raabro::Input.new('tatututo')
#
#        t = Raabro.seq(nil, i, :ta, :tu, '?', :to)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 0, 0, 0, nil, :seq, [
#            [ nil, 1, 0, 2, nil, :str, 'ta' ],
#            [ nil, 1, 2, 2, nil, :str, 'tu' ],
#            [ nil, 0, 4, 0, nil, :str, [] ]
#          ] ]
#        )
#        expect(i.offset).to eq(0)
#      end
#    end
#
#    describe 'the star quantifier' do
#
#      it 'lets optional elements recur in sequences (hit zero)' do
#
#        i = Raabro::Input.new('tato')
#
#        t = Raabro.seq(nil, i, :ta, :tu, '*', :to)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 1, 0, 4, nil, :seq, [
#            [ nil, 1, 0, 2, nil, :str, 'ta' ],
#            [ nil, 0, 2, 0, nil, :str, [] ],
#            [ nil, 1, 2, 2, nil, :str, 'to' ]
#          ] ]
#        )
#        expect(i.offset).to eq(4)
#      end
#
#      it 'lets optional elements recur in sequences (hit)' do
#
#        i = Raabro::Input.new('tatututo')
#
#        t = Raabro.seq(nil, i, :ta, :tu, '*', :to)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 1, 0, 8, nil, :seq, [
#            [ nil, 1, 0, 2, nil, :str, 'ta' ],
#            [ nil, 1, 2, 2, nil, :str, 'tu' ],
#            [ nil, 1, 4, 2, nil, :str, 'tu' ],
#            [ nil, 0, 6, 0, nil, :str, [] ],
#            [ nil, 1, 6, 2, nil, :str, 'to' ]
#          ] ]
#        )
#        expect(i.offset).to eq(8)
#      end
#    end
#
#    describe 'the plus quantifier' do
#
#      it 'lets elements recur in sequences (hit)' do
#
#        i = Raabro::Input.new('tatututo')
#
#        t = Raabro.seq(nil, i, :ta, :tu, '+', :to)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 1, 0, 8, nil, :seq, [
#            [ nil, 1, 0, 2, nil, :str, 'ta' ],
#            [ nil, 1, 2, 2, nil, :str, 'tu' ],
#            [ nil, 1, 4, 2, nil, :str, 'tu' ],
#            [ nil, 0, 6, 0, nil, :str, [] ],
#            [ nil, 1, 6, 2, nil, :str, 'to' ]
#          ] ]
#        )
#        expect(i.offset).to eq(8)
#      end
#
#      it 'lets elements recur in sequences (fail)' do
#
#        i = Raabro::Input.new('tato')
#
#        t = Raabro.seq(nil, i, :ta, :tu, '+', :to)
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 0, 0, 0, nil, :seq, [
#            [ nil, 1, 0, 2, nil, :str, 'ta' ],
#            [ nil, 0, 2, 0, nil, :str, [] ]
#          ] ]
#        )
#        expect(i.offset).to eq(0)
#      end
#    end
