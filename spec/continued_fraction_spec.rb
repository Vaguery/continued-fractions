require 'continued_fractions'

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
    1000.times do
      expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1).calculate).to be_within(0.001).of((1+Math.sqrt(5))/2) # phi
    end
  end

  it "doesn't freak out when it hits a bad value" do
    expect{ ContinuedFraction.new(0,0,0,0,0,1).calculate }.not_to raise_error
  end

  def randconst
    Random.rand(20)+1
  end


  it 'actually coverges' do
    c = ContinuedFraction.new(*(0..50).collect {|i| randconst()}).convergence
    if (c[-1].nan?) then
      expect(c[-2].nan?).to be true # if it in fact doesn't stabilize it flies away, "converging" to NaN
    else
      expect(c[-1]).to eq c[-2]
    end
  end

end

describe 'exactly' do
  it 'gives a rational result' do
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1).exactly).to eq Rational(13,8)
    expect(ContinuedFraction.new(0,1,2,3,-4,5,6,7,-8,9).exactly).to eq Rational(47,55)
  end


  it 'fails "gracefully" for non-integer constants' do
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1).exactly).to eq Rational(13,8)
    expect(ContinuedFraction.new(1,1,1,1,1.1,1,1,1,1,1).exactly).to eq Rational(5104079577686562,3114989742264593)
    expect(ContinuedFraction.new(1,1,1.1,1,1.1,1,1,1,1,1).exactly).to eq Rational(3001691638431373,1875791731588749)
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1.001).exactly).to eq Rational(29284656576976649,18021153908923039)
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1.000000000001).exactly).to eq Rational(7318349394479871,4503599627372185)
    expect(ContinuedFraction.new(1,1.001,1,1,1,1,1,1,1,1).exactly).to eq Rational(29284656576976649,18014398509481984)
    expect(ContinuedFraction.new(1,1.000000000001,1,1,1,1,1,1,1,1).exactly).to eq Rational(7318349394479871,4503599627370496)
    expect(ContinuedFraction.new(1,1,1.001,1,1,1,1,1,1,1).exactly).to eq Rational(2928465657697665,1802565750855041)
    expect(ContinuedFraction.new(1,1,1.000000000001,1,1,1,1,1,1,1).exactly).to eq Rational(5854679515583897,3602879701898649)
  end
end

describe 'convergence' do
  it 'produces a series of b_zero plus` every value for each known pair (not each constant)' do
    expect(ContinuedFraction.new().convergence).to eq [0.0]
    expect(ContinuedFraction.new(1).convergence).to eq [1.0]
    expect(ContinuedFraction.new(1,2).convergence).to eq [1.0, 3.0]
    expect(ContinuedFraction.new(1,2,4).convergence).to eq [1.0, 1.5]
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1,1).convergence).to eq [1.0, 2.0, 1.5, 1.6666666666666665, 1.6, 1.625]
    end
end


describe 'exact_convergence' do
  it 'produces a series of b_zero plus` every value for each known pair (not each constant)' do
    expect(ContinuedFraction.new().exact_convergence).to eq [0]
    expect(ContinuedFraction.new(1).exact_convergence).to eq [1]
    expect(ContinuedFraction.new(1,2).exact_convergence).to eq [1, 3]
    expect(ContinuedFraction.new(1,2,3).exact_convergence).to eq [1.0, Rational(5,3)]
    expect(ContinuedFraction.new(1,1,1,1,1,1,1,1,1,1,1).exact_convergence).to eq [1,2,Rational(3,2),Rational(5,3),Rational(8,5), Rational(13,8)]
    end
end


describe 'exploration' do
  def randomCF(b0,size,scale)
    constants = [b0] + (0..size).collect {rand(scale)+1}
    ContinuedFraction.new(*constants)
  end

  it 'converges' do
    converged = ContinuedFraction.rediscover(Rational(1,1000000),17)
    puts ContinuedFraction.new(*converged).convergence.inspect
  end
end
