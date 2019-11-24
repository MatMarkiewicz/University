
class Fixnum
    def czynniki()
    	res = []
    	for i in (1..self)
    		if self%i == 0
    			res.push i
    	    end
    	end
    	res
    end

    def ack(y)
    	if self == 0
    		y+1
    	elsif y == 0
    		(self-1).ack(1)
        else
        	(self-1).ack(self.ack(y-1))
        end
    end

    def doskonala?()
    	czynniki = self.czynniki[0..-2]
        self == czynniki.inject(0, :+)
    end

    def cyfry()
    	res = []
    	i = self
    	while i != 0
    		res.push i%10
    		i = i/10
		end
		res.reverse
	end

    def slownie()
    	slownik = {
    		0 => "zero",
    		1 => "jeden",
    		2 => "dwa",
    		3 => "trzy",
    		4 => "cztery",
    		5 => "pięć",
    		6 => "sześć",
    		7 => "siedem",
    		8 => "osiem",
    		9 => "dziewięć"
    	}
    	res = []
    	for l in self.cyfry
    		res.push slownik[l]
    	end
    	res.join(" ")
    end

end

puts "Test metody czynniki dla argumentów 6, 13, 64, 100"
puts 6.czynniki.to_s
puts 13.czynniki.to_s
puts 64.czynniki.to_s
puts 100.czynniki.to_s
puts

puts "Test metod acy dla liczby 2 z argumentem 1"
puts 2.ack(1)
puts

puts "Test metody doskonala? dla liczb 6, 10, 28, 100"
puts 6.doskonala?
puts 10.doskonala?
puts 28.doskonala?
puts 100.doskonala?
puts

puts "Test metody slownie dla liczb 15, 100, 123, 1001"
puts 15.slownie
puts 100.slownie
puts 123.slownie
puts 1001.slownie
puts
