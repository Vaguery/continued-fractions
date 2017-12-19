

describe 'ContinuedFraction' do
  it 'is initialized with an array of numbers' do
    expect(ContinuedFraction.new(1,2,3).constants).to eq [1,2,3]
  end

  it 'responds to #b_zero with the first constant, or zero' do
    expect(ContinuedFraction.new(1,2,3).b_zero).to eq 1
    expect(ContinuedFraction.new().b_zero).to eq 0
  end

  it 'responds to #pairs with a list of pairs of constants (not including b_zero)' do
    expect(ContinuedFraction.new(1,2,3).pairs).to eq [[2,3]]
    expect(ContinuedFraction.new(1,2,3,4,5).pairs).to eq [[4, 5], [2, 3]]
    expect(ContinuedFraction.new().pairs).to eq []
  end

  it 'fills in the first pair with 1 if a value is missing' do
    expect(ContinuedFraction.new(1,2).pairs).to eq [[2,1]]
    expect(ContinuedFraction.new(1,2,3,4).pairs).to eq [[4, 1], [2, 3]]
    expect(ContinuedFraction.new().pairs).to eq []
  end
end

describe 'calculating' do
  it 'returns zero as a default for b0' do
    expect(ContinuedFraction.new().calculate).to eq 0.0
  end

  it "returns b0 if that's all there is" do
    expect(ContinuedFraction.new(2).calculate).to eq 2
    expect(ContinuedFraction.new(11).calculate).to eq 11
  end

  it "returns b0+a1 if that's all there is" do
    expect(ContinuedFraction.new(1,2).calculate).to eq 3
  end

  it "returns b0+a1/b1 if that's all there is" do
    expect(ContinuedFraction.new(1,2,3).calculate).to eq (1 + 2.0/3)
    expect(ContinuedFraction.new(0,1,2).calculate).to eq (1.0/2)
  end

  it "returns b0+a1/(b1+a2/1) if that's all there is" do
    expect(ContinuedFraction.new(1,2,3,4).calculate).to eq (1 + 2.0/(3+4))
    expect(ContinuedFraction.new(0,1,2,3).calculate).to eq (0 + 1.0/(2+3))
  end

  it "returns b0+a1/(b1+a2/b2) if that's all there is" do
    expect(ContinuedFraction.new(1,2,3,4,5).calculate).to eq(
      1 + 2 / (3 + 4 / (5 + 0.0)))
    expect(ContinuedFraction.new(0,1,2,3,4).calculate).to eq(
      0 + 1 / (2 + 3 / (4 + 0.0)))
  end

  it 'works for long lists of numbers' do
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1).calculate).to be_within(0.001).of((1+Math.sqrt(5))/2) # phi
  end

  it "doesn't freak out when it hits a bad value" do
    expect{ ContinuedFraction.new(0,0,0,0,0,1).calculate }.not_to raise_error
  end

  def randconst
    Random.rand(20)+1
  end

  # it "handles arbitrary numbers (because I wanted to see it)" do
  #   expect{
  #     File.open("values.csv", 'w') do |file|
  #       v = (0..1000).collect do
  #         cf = ContinuedFraction.new(*(0..50).collect {|i| randconst()})
  #         file.puts("#{cf.calculate},#{cf.constants.join(',')}")
  #         cf
  #       end
  #     end
  #   }.not_to raise_error
  # end

  it 'actually coverges' do
    c = ContinuedFraction.new(*(0..50).collect {|i| randconst()}).convergence
    if (c[-1].nan?) then
      expect(c[-2].nan?).to be true # if it in fact doesn't stabilize it flies away, "converging" to NaN
    else
      expect(c[-1]).to eq c[-2]
    end
  end

end

describe 'convergence' do
  it 'produces a series of b_zero plus` every value for each known pair' do
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1).convergence).to eq [1.0, 2.0, 2.0, 1.5, 1.5, 1.6666666666666665, 1.6666666666666665, 1.6, 1.6, 1.625, 1.625]
  end
end



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

  def convergence
    (0..@constants.length).collect {|a| ContinuedFraction.new(*@constants[0..a]).calculate}
  end
end
