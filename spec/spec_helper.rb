
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

    // various parsers used for testing

    var ta = function(i) { return Jaabro.str(null, i, 'ta'); };
    var to = function(i) { return Jaabro.str(null, i, 'to'); };
    var tu = function(i) { return Jaabro.str(null, i, 'tu'); };

    var nta = function(i) { return Jaabro.str('ta', i, 'ta'); };
    var to_plus = function(i) { return Jaabro.rep('tos', i, to, 1); };

    var cha = function(i) { return Jaabro.rex(null, i, /[a-z]/); };
    var com = function(i) { return Jaabro.str(null, i, ','); };

    var lt = function(i) { return Jaabro.str(null, i, '<'); };
    var gt = function(i) { return Jaabro.str(null, i, '>'); };

    var onex = function(i) { return Jaabro.str('onex', i, 'x'); };
    var twox = function(i) { return Jaabro.str('twox', i, 'xx'); };
    var deux = function(i) { return Jaabro.str('deux', i, 'xx'); };
  }

def js(s)

  ExecJS.compile($source).exec(s)
end

