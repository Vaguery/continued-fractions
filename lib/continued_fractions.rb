class ContinuedFraction
  attr_accessor :constants

  def initialize(*constants)
    @constants = constants
  end

  def b_zero
    @constants[0] || 0.0
  end

  def pairs
    values = @constants.drop(1)
    pairs = values.each_slice(2).to_a
    pairs[-1] = pairs[-1]+[1] if (pairs[-1] && pairs[-1].length == 1)
    return pairs.reverse
  end

  def calculate
    result = b_zero + pairs.reduce(0.0) do |c,pair|
      pair[0] / (pair[1] + c)
    end
    return result
  end

  def exactly
    begin
      result = b_zero + pairs.reduce(0) do |c,pair|
        Rational(pair[0], (pair[1] + c))
      end
    rescue ZeroDivisionError
      result = nil
    end
    return result
  end

  def convergence
    (0..@constants.length/2).collect {|a| ContinuedFraction.new(*@constants[0..(2*a)]).calculate}
  end

  def exact_convergence
    (0..@constants.length/2).collect {|a| ContinuedFraction.new(*@constants[0..(2*a)]).exactly}
  end



  def self.randomVariants(c_list)
    nonzero = (-10..1).to_a + (1..10).to_a
    variants = c_list.length.times.collect do |v|
      c_list.collect.with_index do |i,idx|
        if rand() < 0.1
          if idx.zero?
            i + rand(9) - 4
          elsif idx.odd?
            (rand() < 0.01) ? nonzero.sample : (i + rand(9) - 4)
          else
            (rand() < 0.01) ? nonzero.sample : (i + rand(9) - 4)
          end
        else
          i
        end
      end
    end
    return variants.uniq + [c_list]
  end

  def self.error(x1,x2)
    (x1.nil? || x2.nil?) ? Float::INFINITY : (x1-x2).abs
  end

  def self.rediscover(target,terms)
    nonzero = (1..10).to_a + (-10..1).to_a
    c1 = terms.times.collect {nonzero.sample}
    (1..100000).each do |i|
      break if ContinuedFraction.new(*c1).exactly == target
      old = c1
      which = rand(terms-2) + 2
      c2s = []
      until not c2s.empty?
        c2s = randomVariants(c1).reject do |variant|
          value = ContinuedFraction.new(*variant[0..which]).exactly
          value.nil? || value.zero?
        end
      end
      c2s = c2s.shuffle.sort_by do |i|
        error(ContinuedFraction.new(*i[0..which]).exactly,target)
      end
      c2 = c2s[0]
      e1 = error(ContinuedFraction.new(*c1[0..which]).exactly,target)
      e2 = error(ContinuedFraction.new(*c2[0..which]).exactly,target)
      c1 = (e1 <= e2) ? c1 : c2
      puts "(#{i}) #{target} : #{error(ContinuedFraction.new(*c1).calculate,target)} #{c1}" if (i % 1000 == 0)
    end
    if ContinuedFraction.new(*c1).exactly == target
      puts "converged: #{c1}"
    else
      puts "failed to converge"
    end
    cf1 = ContinuedFraction.new(*c1)
    errs = cf1.convergence.collect {|v| error(v,target)}
    return c1
  end
end
