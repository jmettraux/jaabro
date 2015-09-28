
#
# specifying jaabro
#
# Tue Sep 29 06:50:39 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  it 'works' do

    p js_exec(%{

      var MyParser = Jaabro.make({
        root: function(input) { return this.str("title", input, "title"); }
      });

      return MyParser.parse("title");
    })
  end
end

