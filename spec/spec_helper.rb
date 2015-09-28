
#
# Specifying jaabro
#
# Mon Sep 28 20:58:58 JST 2015
#

require 'pp'
require 'execjs'


$source = File.read('src/jaabro.js')

def js_exec(s)

  ExecJS.compile($source).exec(s)
end

