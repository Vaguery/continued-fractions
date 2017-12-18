
describe 'ContinuedFraction' do
  it 'is initialized with an array of numbers' do
    expect(ContinuedFraction.new([1,2,3]).constants).to eq [1,2,3]
  end

  it 'responds to #b_values by returning the odd-indexed constants' do
    expect(ContinuedFraction.new([9,99,999]).b_values).to eq [9,999]
    expect(ContinuedFraction.new([-1,-2,-3,-4,-5]).b_values).to eq [-1,-3,-5]
    expect(ContinuedFraction.new([1]).b_values).to eq [1]
  end

  it 'responds to #a_values by returning the even-indexed constants' do
    expect(ContinuedFraction.new([9,99,999]).a_values).to eq [99]
    expect(ContinuedFraction.new([-1,-2,-3,-4,-5]).a_values).to eq [-2,-4]
    expect(ContinuedFraction.new([1]).a_values).to eq []
  end
end




class ContinuedFraction
  attr_accessor :constants

  def initialize(constants)
    @constants = constants
  end

  def b_values
    @constants.reject.with_index {|k,i| i.odd?}
  end

  def a_values
    @constants.reject.with_index {|k,i| i.even?}
  end
end
