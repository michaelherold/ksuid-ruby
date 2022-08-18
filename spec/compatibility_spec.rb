# frozen_string_literal: true

require 'time'

RSpec.describe 'compatibility tests', type: :compatibility do
  it 'handles the maximum properly', :aggregate_failures do
    ksuid = KSUID.from_base62('aWgEPTl1tmebfsQzFP4bxwgy80V')

    expect(ksuid.to_s).to eq('aWgEPTl1tmebfsQzFP4bxwgy80V')
    expect(ksuid.to_time).to eq(Time.parse('2150-06-19 17:21:35 -0600 CST'))
    expect(ksuid.to_i).to eq(4_294_967_295)
    expect(ksuid.payload).to eq('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')
    expect(ksuid.raw).to eq('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF')
  end

  it 'handles the minimum properly', :aggregate_failures do
    ksuid = KSUID.from_base62('000000000000000000000000000')

    expect(ksuid.to_s).to eq('000000000000000000000000000')
    expect(ksuid.to_time).to eq(Time.parse('2014-05-13 11:53:20 -0500 CDT'))
    expect(ksuid.to_i).to eq(0)
    expect(ksuid.payload).to eq('00000000000000000000000000000000')
    expect(ksuid.raw).to eq('0000000000000000000000000000000000000000')
  end

  it 'handles an example value', :aggregate_failures do
    ksuid = KSUID.from_base62('0vdbMgWkU6slGpLVCqEFwkkZvuW')

    expect(ksuid.to_s).to eq('0vdbMgWkU6slGpLVCqEFwkkZvuW')
    expect(ksuid.raw).to eq('0683F789049CC215C099D42B784DBE99341BD79C')
    expect(ksuid.to_time).to eq(Time.parse('2017-10-29 16:18:01 -0500 CDT'))
    expect(ksuid.to_i).to eq(109_311_881)
    expect(ksuid.payload).to eq('049CC215C099D42B784DBE99341BD79C')
  end

  it 'handles another example value', :aggregate_failures do
    ksuid = KSUID.from_base62('0vdbMkSk7XwvMeKS6aZMM2AVZ4G')

    expect(ksuid.to_s).to eq('0vdbMkSk7XwvMeKS6aZMM2AVZ4G')
    expect(ksuid.to_time).to eq(Time.parse('2017-10-29 16:18:01 -0500 CDT'))
    expect(ksuid.to_i).to eq(109_311_881)
    expect(ksuid.payload).to eq('85EAB6C3F1809D7D4A00760CCBF7707C')
    expect(ksuid.raw).to eq('0683F78985EAB6C3F1809D7D4A00760CCBF7707C')
  end
end
