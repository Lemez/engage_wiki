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
require_relative './lib/uri'
require_relative './lib/string'


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
	@file = open(".results/5_results_#{@min}-#{@secs}.txt", "w") if @writing

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
					next unless sentence.starts_with_a_capital

					@full_stop_array << sentence if sentence.include?("\.") and @full_stop_array.length<5 
					@comma_array << sentence if sentence.include?(",") and @comma_array.length<5
					@semicolon_array << sentence if sentence.include?(";") and @semicolon_array.length<5
					@colon_array << sentence if sentence.include?(":") and @colon_array.length<5
					@question_array << sentence if sentence.include?("?") and @question_array.length<5
					@excl_array << sentence if sentence.include?("!") and @excl_array.length<5
					@single_quote_array << sentence if sentence.include?("\'") and @single_quote_array.length<5
					@double_quote_array << sentence if sentence.include?('"') and @double_quote_array.length<5
					@hyphen_array << sentence if sentence.include?("-")	and @hyphen_array.length<5
					
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
		p "******"
		
	end

	@file.write @results_hash.to_json if @writing
	@file.close	if @writing

end

@results_hash = {}
get_sentences

