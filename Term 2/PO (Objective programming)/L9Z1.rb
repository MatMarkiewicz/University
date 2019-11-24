class Integer
	def my_to_s
		res = ""
		if self >= 0
			for i in 0..(4-self.to_s.length)
				res += 0.to_s
			end
			res += self.to_s
			res += " "
		else
			res += "-"
			for i in 0..(4-self.to_s.length)
				res += 0.to_s
			end
			res += self.abs.to_s
			res += " "
		end
	end
end

class Float
	def my_to_s
		res = ""
		if self >= 0
			res += self.round(2).to_s
			for i in 0..(4-self.round(2).to_s.length)
				res += 0.to_s
			end
			res += " "
		else
			res += "-"
			res += self.round(2).abs.to_s
			for i in 0..(4-self.round(2).to_s.length)
				res += 0.to_s
			end
			res += " "
		end
	end
end

class Function
	def initialize(d)
		@def = d
	end

	def value(x)
		@def.call(x)
	end

	def zerowe(a,b,e)
		a = a
		b = b
		c = (a+b)/2.0
		fc = value(c)
		fa = value(a)
		fb = value(b)
		if fa*fb > 0
			nil
		else
			while (a-b).abs > e
				c = (a+b)/2.0
				fc = value(c)
				if fc.abs <= e
					return c
				elsif fa*fc < 0
					b = c
				else
					a = c
				end
			end
            c
		end
	end

	def pole(a,b)
		n = 1000.0
		podzial = (b-a)/n
		suma = 0.0
		for i in 1..n
			suma += podzial * value(a + (i-1)*podzial)
		end
		suma
	end

	def poch(x)
		e = 0.00000000000001
		(value(x+e) - value(x)) / e
	end

	def podzial(a,b,s)
		while b-a >= 10*s
			print a.to_s
			for i in (1..(10-a.to_s.length))
				print "_"
			end
			a += 10*s
		end
		print a.to_s
	end

	def rysuj(a,b,h,s)
		for i in (0..2*h).step s
			print (h-i).my_to_s
			for j in (a..b).step s
				if value(j) >= h-i and (value(j) < h-i+s or value(j-s) < h-i or value(j+s) < h-i)
					print "#"
				else
					print " "
				end
			end
			puts
			if i == h
				print "      "
				podzial(a,b,s)
				puts
			end
		end
	end
end

log = proc { |x| 4*(Math.log 0.1*x)}
sin = proc { |x| 7 * (Math.sin 0.1*x)}
kwadratowa = proc { |x| (0.1*x) ** 2}
kwadratowa2 = proc { |x| (0.1*x) ** 2 + x}
blok = proc { |x| Math.sin x}
test = Function.new(blok)
test.rysuj(-10,10,1,0.1)
puts
puts
test2 = Function.new( proc { |x| x})
p test2.value(5)
p test2.zerowe(-1,1,0.00001)
p test2.poch(3)
p test2.pole(0,10)




