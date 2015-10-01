
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
end

