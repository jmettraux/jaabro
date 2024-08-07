
#
# Specifying jaabro
#
# Mon Sep 28 20:58:58 JST 2015
#

require 'pp'
require 'ferrum'


JAABRO_SOURCE =
  File.read('src/jaabro.js') +
  %{
    // various parsers used for testing

    var ta = function(i) { return Jaabro.str(null, i, 'ta'); };
    var to = function(i) { return Jaabro.str(null, i, 'to'); };
    var tu = function(i) { return Jaabro.str(null, i, 'tu'); };

    var nta = function(i) { return Jaabro.str('ta', i, 'ta'); };
    var to_plus = function(i) { return Jaabro.rep('tos', i, to, 1); };
    var to_star = function(i) { return Jaabro.rep('tos', i, to, 0); };

    var cha = function(i) { return Jaabro.rex(null, i, /[a-z]/); };
    var com = function(i) { return Jaabro.str(null, i, ','); };

    var lt = function(i) { return Jaabro.str(null, i, '<'); };
    var gt = function(i) { return Jaabro.str(null, i, '>'); };

    var onex = function(i) { return Jaabro.str('onex', i, 'x'); };
    var twox = function(i) { return Jaabro.str('twox', i, 'xx'); };
    var deux = function(i) { return Jaabro.str('deux', i, 'xx'); };

    var acom = function(i) { return Jaabro.rex(null, i, /,?/); };
    var aval = function(i) { return Jaabro.rex(null, i, /[a-z]?/); };
    var arr = function(i) { return Jaabro.eseq(null, i, lt, aval, acom, gt); };
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

      let root = exp;

      //
      // rewrite

      function rewrite_num(t) { return parseInt(t.string(), 10); }

      function rewrite_fun(t) {
        let a = [];
        a.push(t.children[0].string());
        t.children[1].children.forEach(function(c) {
          if (c.name) a.push(rewrite(c));
        });
        return a;
      }

      function rewrite_exp(t) { return rewrite(t.children[0]); }
    });
  }

XELL =
  %{
    var Xell = Jaabro.make(function() {

      //
      // parse

      function pa(i) { return rex(null, i, /\\(\\s*/); }
      function pz(i) { return rex(null, i, /\\s*\\)/); }
      function com(i) { return str(null, i, ','); }

      function num(i) { return rex('num', i, /\\s*-?[0-9]+\\s*/); }

      function args(i) { return eseq(null, i, pa, exp, com, pz); }
      function funame(i) { return rex(null, i, /[A-Z][A-Z0-9]* */); }
      function fun(i) { return seq('fun', i, funame, args); }

      function exp(i) { return alt(null, i, fun, num); }

      let root = exp;

      //
      // rewrite

      function rewrite_num(t) {
        return parseInt(t.string(), 10);
      }

      function rewrite_fun(t) {
        let a = [];
        a.push(t.children[0].string());
        t.children[1].oddChildren().forEach(
          function(c) { a.push(rewrite(c)); });
        return a;
      }
    });
  }

SPACE_WRAPPER =
  %{
    var SpaceWrapper = Jaabro.makeParser(function() {

      function exp(i) { return str('exp', i, 'EXP'); }
      function prespace(i) { return rex(null, i, /\s+/); }
      function root(i) { return seq(null, i, prespace, '?', exp); }

      function rewrite_exp(t) { return t.name; }
    });
  }


module Helpers

  def js(s)

    $browser ||=
      begin
        Ferrum::Browser.new(js_errors: true)
      end

    s1 =
      "JSON.stringify((function() { #{JAABRO_SOURCE}; #{s}; })())"
    j =
      begin
        $browser.evaluate(s1)
      rescue Ferrum::DeadBrowserError
        $browser = nil
        return js(s)
      end

    JSON.parse(j)
  end
end
RSpec.configure { |c| c.include(Helpers) }

RSpec::Expectations.configuration .warn_about_potential_false_positives = false

