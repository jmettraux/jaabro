
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
        }.to raise_error(
          Ferrum::JavaScriptError, /Error: lonely quantifier 'qmark'/
        )
      end

      it 'throws an error' do

        expect {
          js(%{
            var i = Jaabro.makeInput('something');
            return Jaabro.seq('n0', i, '?');
          })
        }.to raise_error(
          Ferrum::JavaScriptError, /Error: lonely quantifier 'qmark'/
        )
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

      it 'lets optional elements appear in sequences (hit)' do

        expect(js(%{

          var i = Jaabro.makeInput('tatuto');
          var r = Jaabro.seq('n0', i, ta, tu, '?', to);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'n0', 1, 0, 6, 'seq', [
              [ nil, 1, 0, 2, 'str', 'ta' ],
              [ nil, 1, 2, 2, 'str', 'tu' ],
              [ nil, 1, 4, 2, 'str', 'to' ]
            ] ],
            6
          ]
        )
      end

      it 'lets optional elements appear in sequences (fail)' do

        expect(js(%{

          var i = Jaabro.makeInput('tatututo');
          var r = Jaabro.seq('n0', i, ta, tu, '?', to);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'n0', 0, 0, 0, 'seq', [
              [ nil, 1, 0, 2, 'str', 'ta' ],
              [ nil, 1, 2, 2, 'str', 'tu' ],
              [ nil, 0, 4, 0, 'str', [] ]
            ] ],
            0
          ]
        )
      end
    end

    describe 'the star quantifier' do

      it 'lets optional elements recur in sequences (hit zero)' do

        expect(js(%{

          var i = Jaabro.makeInput('tato');
          var r = Jaabro.seq('n0', i, ta, tu, '*', to);

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

      it 'lets optional elements recur in sequences (hit)' do

        expect(js(%{

          var i = Jaabro.makeInput('tatututo');
          var r = Jaabro.seq('n0', i, ta, tu, '*', to);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'n0', 1, 0, 8, 'seq', [
              [ nil, 1, 0, 2, 'str', 'ta' ],
              [ nil, 1, 2, 2, 'str', 'tu' ],
              [ nil, 1, 4, 2, 'str', 'tu' ],
              [ nil, 0, 6, 0, 'str', [] ],
              [ nil, 1, 6, 2, 'str', 'to' ]
            ] ],
            8
          ]
        )
      end

      it 'stops when there is no progress' do

        expect(js(%{

          var i = Jaabro.makeInput('abc');
          var r = Jaabro.seq(null, i, to_star, '*');

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq([
          [nil, 1, 0, 0, "seq", [
            ["tos", 1, 0, 0, "rep", [
              [nil, 0, 0, 0, "str", []]]]]],
          0
        ])
      end
    end

    describe 'the plus quantifier' do

      it 'lets elements recur in sequences (hit)' do

        expect(js(%{

          var i = Jaabro.makeInput('tatututo');
          var r = Jaabro.seq('n0', i, ta, tu, '+', to);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'n0', 1, 0, 8, 'seq', [
              [ nil, 1, 0, 2, 'str', 'ta' ],
              [ nil, 1, 2, 2, 'str', 'tu' ],
              [ nil, 1, 4, 2, 'str', 'tu' ],
              [ nil, 0, 6, 0, 'str', [] ],
              [ nil, 1, 6, 2, 'str', 'to' ]
            ] ],
            8
          ]
        )
      end

      it 'lets elements recur in sequences (fail)' do

        expect(js(%{

          var i = Jaabro.makeInput('tato');
          var r = Jaabro.seq('n0', i, ta, tu, '+', to);

          return [ r.toArray({ leaves: true }), i.offset ];
        })).to eq(
          [
            [ 'n0', 0, 0, 0, 'seq', [
              [ nil, 1, 0, 2, 'str', 'ta' ],
              [ nil, 0, 2, 0, 'str', [] ]
            ] ],
            0
          ]
        )
      end

      it 'stops when there is no progress' do

#        i = Raabro::Input.new('abc')
#
#        t = Raabro.seq(nil, i, :to_star, '+');
#
#        expect(t.to_a(:leaves => true)).to eq(
#          [ nil, 1, 0, 0, nil, :seq, [
#            [ nil, 1, 0, 0, nil, :rep, [
#              [ nil, 0, 0, 0, nil, :str, [] ]
#            ] ]
#          ] ]
#        )
      end
    end

    describe 'the exclamation mark' do

      it 'throws an error when lonely' do

        expect {
          js(%{
            var i = Jaabro.makeInput('something');
            return Jaabro.seq('n0', i, '!');
          })
        }.to raise_error(
          Ferrum::JavaScriptError, /Error: lonely quantifier 'bang'/
        )
      end

      it 'hits post' do

        r =
          js(%q{

            var i = Jaabro.makeInput('tatu');
            var r = Jaabro.seq('seq0', i, ta, ta, '!');

            return [ r.toArray({ leaves: true }), r.string(), i.offset ];
          })

        expect(r).to eq([
          [ 'seq0', 1, 0, 2, 'seq', [
            [ nil, 1, 0, 2, 'str', 'ta' ],
            [ nil, 1, 2, 0, 'nott', [
              [ nil, 0, 2, 0, 'str', [] ] ] ] ] ],
          'ta',
          2
        ])
      end

      it 'misses post' do

        r =
          js(%q{

            var i = Jaabro.makeInput('tata');
            var r = Jaabro.seq('seq0', i, ta, ta, '!');

            return [ r.toArray({ leaves: true }), r.string(), i.offset ];
          })

        expect(r).to eq([
          [ 'seq0', 0, 0, 0, 'seq', [
            [ nil, 1, 0, 2, 'str', 'ta' ],
            [ nil, 0, 2, 0, 'nott', [
              [ nil, 1, 2, 2, 'str', 'ta' ] ] ] ] ],
          '',
          0
        ])
      end

      it 'hits pre' do

        r =
          js(%q{

            var i = Jaabro.makeInput('tatu');
            var r = Jaabro.seq('seq0', i, tu, '!', ta, tu);

            return [ r.toArray({ leaves: true }), r.string(), i.offset ];
          })

        expect(r).to eq([
          [ 'seq0', 1, 0, 4, 'seq', [
            [ nil, 1, 0, 0, 'nott', [
              [ nil, 0, 0, 0, 'str', [] ] ] ],
            [ nil, 1, 0, 2, 'str', 'ta' ],
            [ nil, 1, 2, 2, 'str', 'tu' ] ] ],
          'tatu',
          4
        ])
      end

      it 'misses pre' do

        r =
          js(%q{

            var i = Jaabro.makeInput('tutu');
            var r = Jaabro.seq('seq0', i, tu, '!', ta, tu);

            return [ r.toArray({ leaves: true }), r.string(), i.offset ];
          })

        expect(r).to eq([
          [ 'seq0', 0, 0, 0, 'seq', [
            [ nil, 0, 0, 0, 'nott', [
              [ nil, 1, 0, 2, 'str', 'tu' ] ] ] ] ],
          '',
          0
        ])
      end
    end
  end
end

