# usage - 
# ruby script.rb true/false 
# if you do or dont want to write to file

# require 'httparty'
require 'nokogiri'
require 'google_drive'
require 'CGI'
require 'active_support/all'
require 'net/http'
require 'open-uri'
require 'awesome_print'
require "addressable/uri"
require_relative './uri'
require_relative './string'


# extract band name from spreadsheet
@bands = ["One_Direction","Taylor_Swift","OneRepublic","Sam_Smith_(singer)","Coldplay"]

# get wikipedia articles
@sites = ['https://simple.wikipedia.org/wiki/',"https://en.wikipedia.org/wiki/"] # nb multiple words separated by '_'

# get which items we are looking for
@punctuation = [ "\.", ",", "?", "!", ";", ":", "\'",'"',"-"]
@punctuation_arrays = [@full_stop_array,@comma_array,@question_array,@excl_array,@semicolon_array,@colon_array,
	@single_quote_array,@double_quote_array,@hyphen_array]

# determine if we are writing to file or not
@writing = ARGV[0]
@secs = Time.now.sec
@min = Time.now.min

def get_sentences 
	@file = open("./results_#{@min}-#{@secs}.txt", "w") if @writing

	@bands.each do |band|
		p "fetching #{band}"
		@site_hash = {}
		@sites.each do |site|
			@base_url = site
			@root = @base_url[@base_url.index('/')+2...@base_url.index('.')]
			p @root
			@punc_hash = {}
			@full_stop_array = []
			@comma_array = []
			@semicolon_array = []
			@colon_array = []
			@question_array = []
			@excl_array = []
			@single_quote_array = []
			@double_quote_array = []
			@hyphen_array = []

			url_string = "#{@base_url}#{band}".strip
			article = open(url_string)
			result = Nokogiri::HTML(article)

			result.css('p').each do |para|

				text = para.text.scan(/(?:"(?>[^"]|\\.)+"|[a-z]\.[a-z]\.|[^.?!])+[!.?]/).map(&:strip)

	 # Check for:			 
    # 1.A quoted string in the form of "quote" which can contain anything up until the ending quote. You can also have escaped quotes, such as "hell\"o".
    # 2.Match any letter, followed by a dot, followed by another letter, and finally a dot. This is to match your special case of U.S. etc.
    # 3.Match everything else that isn't a punctation character .?!.
    # 4.Repeat up until we reach a punctation character.

				text.each do |sentence|

					# a = sentence.dup
					sentence.gsub!(/\[[0-9]+\]/, "") if sentence.include?("]")
					sentence.lstrip! if sentence[0]==" "
					# p sentence if a!=sentence

					next if sentence[0] != sentence[0].upcase

					@full_stop_array << sentence if sentence.include?("\.")
					@comma_array << sentence if sentence.include?(",")
					@semicolon_array << sentence if sentence.include?(";")
					@colon_array << sentence if sentence.include?(":")
					@question_array << sentence if sentence.include?("?")
					@excl_array << sentence if sentence.include?("!")
					@single_quote_array << sentence if sentence.include?("\'")
					@double_quote_array << sentence if sentence.include?('"')
					@hyphen_array << sentence if sentence.include?("-")	
					
				end
			end

			@punc_hash["\."] =  @full_stop_array
			@punc_hash[","] =  @comma_array
			@punc_hash[";"] =  @semicolon_array
			@punc_hash[":"] =  @colon_array
			@punc_hash["?"] =  @question_array
			@punc_hash["!"] =  @excl_array
			@punc_hash["\'"] =  @single_quote_array
			@punc_hash['"'] =  @double_quote_array
			@punc_hash["-"] =  @hyphen_array
			@site_hash[@root] = @punc_hash

		end	
		@results_hash[band] = @site_hash
		p "completed #{band}"
		
	end

	@file.write @results_hash.to_json if @writing
	@file.close	if @writing

end

@results_hash = {}
get_sentences

