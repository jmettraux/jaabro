
#
# specifying jaabro
#
# Fri Dec 25 15:28:50 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'Jaabro.Tree' do

    describe '.lookup(name)' do

      it 'returns null when it finds nothing' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.lookup('funk');
        })).to eq(
          nil
        )
      end

      it 'returns the first matching node (depth first)' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.children[0].lookup('exp').toString();
        })).to eq(%{
1 "exp" 4,1
  1 "num" 4,1 "7"
        }.strip)
      end

      it 'returns the first named node when given null as name' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.children[0].children[1].lookup(null).toString();
        })).to eq(%{
1 "exp" 4,1
  1 "num" 4,1 "7"
        }.strip)
      end
    end

    describe '.sublookup(name)' do

      it 'returns the first node with the give name' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.sublookup('exp').toString();
        })).to eq(%{
1 "exp" 4,1
  1 "num" 4,1 "7"
        }.strip)
      end

      it 'returns the first named node when name is null' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.children[0].sublookup(null).toString();
        })).to eq(%{
1 "exp" 4,1
  1 "num" 4,1 "7"
        }.strip)
      end
    end

    describe '.gather(name)' do

      it 'returns [] when it finds nothing' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          return r.children[0].gather('funk');
        })).to eq(
          []
        )
      end

      it 'returns all the matching nodes (depth first)' do

        expect(js(XEL + %{
          var r = Xel.parse('MUL(7,-3)', { rewrite: false });
          var ns = r.children[0].gather('exp');
          var a = []; ns.forEach(function(n) { a.push(n.toString()); });
          return a.join('\\n---\\n');
        })).to eq(%{
1 "exp" 4,1
  1 "num" 4,1 "7"
---
1 "exp" 6,2
  1 "num" 6,2 "-3"
        }.strip)
      end

      it 'returns all the named subtrees when given null as name'
    end

    describe '.subgather(name)' do

      it 'works'
    end
  end
end

