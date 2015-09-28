
#
# specifying jaabro
#
# Mon Sep 28 21:08:18 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  describe 'str' do

    it 'flips burgers' do

      p js_exec(%{
        return MyParser.parse("hello world");
      })
    end
  end
end

