class String
	def contains_unclosed_quotes
		 return self.count('"') % 2
	end

	def starts_with_a_capital
		return self[0..0] =~ /[A-Z]/
	end
end