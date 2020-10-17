#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'nokogiri'
end

require 'fileutils'
require 'json'
require 'open-uri'
require 'pathname'

$VERBOSE=nil

pdfs = {}

(15..19).each do |yy|
  ['Licei', 'IstitutiProfessionali', 'IstitutiTecnici'].each do |page|
    noko = Nokogiri::HTML URI.open("https://www.istruzione.it/esame_di_stato/20#{yy-1}#{yy}/#{page}.htm")

    noko.css('h4').each do |h4|
      indirizzo = h4.text.strip

      h4.parent.next_element.css('a').each do |a|
        pdfs["20#{yy}"] ||= {}
        pdfs["20#{yy}"]["20#{yy-1}#{yy}/#{a['href']}"] = indirizzo
      end
    end
  end
end

File.write("pdfs.json", JSON.pretty_generate(pdfs))

pdfs.each do |_, v|
  v.each do |k, _|
    p k
    FileUtils.mkdir_p(Pathname.new(k).dirname)
    stream = URI.open(URI.encode("https://www.istruzione.it/esame_di_stato/#{k}")) rescue next
    IO.copy_stream(stream, k)
  end
end
