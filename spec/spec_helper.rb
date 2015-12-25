
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

XEL =
  %{
    var Xel = Jaabro.make(function() {

      //
      // parse

      function pa(i) { return str(null, i, '('); }
      function pz(i) { return str(null, i, ')'); }
      function com(i) { return str(null, i, ','); }

      function num(i) { return rex('num', i, /-?[0-9]+/); }

      function args(i) { return eseq(null, i, pa, exp, com, pz); }
      function funame(i) { return rex(null, i, /[A-Z][A-Z0-9]*/); }
      function fun(i) { return seq('fun', i, funame, args); }

      function exp(i) { return alt('exp', i, fun, num); }

      var root = exp;

      //
      // rewrite

      function rewrite_num(t) { return parseInt(t.string(), 10); }

      function rewrite_fun(t) {
        var a = [];
        a.push(t.children[0].string());
        t.children[1].children.forEach(function(c) {
          if (c.name) a.push(rewrite(c));
        });
        return a;
      }

      function rewrite_exp(t) { return rewrite(t.children[0]); }
    });
  }

def js(s)

  ExecJS.compile($source).exec(s)
end

