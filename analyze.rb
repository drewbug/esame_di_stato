#!/usr/bin/env ruby

require 'json'
require 'pathname'

pdfs = JSON.parse(File.read('pdfs.json'))

pdfs.each do |yyyy, v|
  puts "[#{yyyy}]\n"
  
  v.each do |k, indirizzo|
    path = Pathname.new(k)

    next unless path.exist?

    if path.extname == '.pdf'
      system('pdftotext', k)

      lines = File.readlines(path.sub_ext('.txt'))

      tema_i = lines.find_index { |line| line.include? 'Tema' }
      next if tema_i.nil?

      inglese_i = lines.find_index { |line| line.match(/inglese/i) }
      next if inglese_i.nil?

      next if tema_i > inglese_i

      if (inglese_i - tema_i) < 3
        p indirizzo
        print "=> "
        p lines[tema_i..inglese_i].join.strip
      end
    end
  end

  puts
end
