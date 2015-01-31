class String
	def self.contains_unclosed_quotes
		return self.count('"') % 2
	end
end