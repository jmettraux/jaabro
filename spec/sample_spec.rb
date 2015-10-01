
#
# specifying jaabro
#
# Thu Oct  1 15:02:18 JST 2015
#

require 'spec_helper'


NO_ROOT =
  %{
    var NoRoot = Jaabro.make(function() {

      function hello(i) { return str(null, i, 'hello'); }
    });
  }

OWN_REWRITE =
  %{
    var OwnRewrite = Jaabro.make(function() {

      function root(i) { return str(null, i, 'hello'); }

      function rewrite(t) { return "rewritten"; }
    });
  }


describe 'jaabro.js' do

  describe 'NoRoot' do

    it 'complains there is no root parser' do

      expect {
        js(NO_ROOT)
      }.to raise_error(
        ExecJS::ProgramError, 'Error: missing function root() parser'
      )
    end
  end

  describe 'OwnRewrite' do

    it 'provides its own rewrite(t) implementation' do

      expect(js(OWN_REWRITE + %{
        return OwnRewrite.parse('hello')
      })).to eq(
        'rewritten'
      )
    end
  end
end

