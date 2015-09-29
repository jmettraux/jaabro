
#
# Specifying jaabro
#
# Mon Sep 28 20:58:58 JST 2015
#

require 'pp'
require 'execjs'


$source =
  File.read('src/jaabro.js') +
  %{
    var ta = function(i) { return Jaabro.str(null, i, 'ta'); };
    var to = function(i) { return Jaabro.str(null, i, 'to'); };
    var tu = function(i) { return Jaabro.str(null, i, 'tu'); };

    var nta = function(i) { return Jaabro.str('ta', i, 'ta'); };
    var to_plus = function(i) { return Jaabro.rep('tos', i, to, 1); };
  }

def js(s)

  ExecJS.compile($source).exec(s)
end

