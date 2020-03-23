
# see ../LICENSE.txt for license

STDIN.readlines.each do |line|

  l = line.strip

  next if l == ''
  next if l.match(/\A\/\//)

  print "\n" unless %w[ } }; }); { ].include?(l)
  print l
end

