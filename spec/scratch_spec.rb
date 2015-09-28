
#
# specifying jaabro
#
# Tue Sep 29 06:50:39 JST 2015
#

require 'spec_helper'


describe 'jaabro.js' do

  it 'works' do

    expect(js(%{

      var MyParser = Jaabro.make({
        root: function(input) { return this.str("title", input, "title"); }
      });

      return MyParser.parse("title");
    }).class).to eq(Hash)
  end
end

