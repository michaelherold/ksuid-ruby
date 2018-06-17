# frozen_string_literal: true

RSpec.describe KSUID::Type do
  describe '#initialize' do
    it 'generates a payload when one is not passed' do
      expect(KSUID::Type.new.payload).not_to be_nil
      expect(KSUID::Type.new(payload: nil).payload).not_to be_nil
    end

    it 'generates a timestamp when one is not passed' do
      now = Time.parse('2018-06-17 23:10:20 -0500')
      payload = "\xFF" * 16
      expected = '16At1su4a88N9Mg0fSgwq6a4umV'

      Timecop.freeze(now) do
        expect(KSUID::Type.new(payload: payload).to_s).to eq(expected)
      end
    end
  end

  describe '#<=>' do
    it 'sorts the KSUIDs by timestamp' do
      Timecop.freeze do
        ksuid1 = KSUID.new(time: Time.now)
        ksuid2 = KSUID.new(time: Time.now + 1)

        array = [ksuid2, ksuid1].sort

        expect(array).to eq([ksuid1, ksuid2])
        expect(ksuid1 <=> ksuid2).to eq(-1)
        expect(ksuid1 <=> ksuid1).to eq(0) # rubocop:disable Lint/UselessComparison
        expect(ksuid2 <=> ksuid1).to eq(1)
      end
    end
  end

  describe '#==' do
    it 'works' do
      ksuid = KSUID.max

      expect(ksuid == 'aWgEPTl1tmebfsQzFP4bxwgy80V').to be(true)
      expect(ksuid == KSUID.max).to be(true)
      expect(ksuid == '').to be(false)
    end
  end

  describe '#inspect' do
    it 'shows the string representation for easy understanding' do
      ksuid = KSUID.max

      expect(ksuid.inspect).to eq('<KSUID(aWgEPTl1tmebfsQzFP4bxwgy80V)>')
    end
  end

  describe '#payload' do
    it 'returns the payload as a byte string' do
      bytes = KSUID.from_base62('16AFlKJgs5TiMSZwUrJWyfIznLI').payload

      expect(bytes).to eq('F536AD71E1815D2202FD994175B3DA04')
    end
  end

  describe '#raw' do
    it 'returns the payload as a hex-encoded string' do
      hex = KSUID.from_base62('16AFlKJgs5TiMSZwUrJWyfIznLI').raw

      expect(hex).to eq('07B496FFF536AD71E1815D2202FD994175B3DA04')
    end
  end

  describe '#to_bytes' do
    it 'returns the ksuid as a byte string' do
      expected = [
        7, 180, 150, 255, 245, 54, 173, 113, 225, 129, 93, 34, 2, 253, 153, 65,
        117, 179, 218, 4
      ]

      array = KSUID.from_base62('16AFlKJgs5TiMSZwUrJWyfIznLI').to_bytes.bytes

      expect(array).to eq(expected)
    end
  end

  describe '#to_time' do
    it 'returns the times used to create the ksuid' do
      time = Time.at(Time.now.to_i)

      ksuid = KSUID.new(time: time)

      expect(ksuid.to_time).to eq(time)
    end
  end

  describe '#to_s' do
    it 'correctly represents the maximum value' do
      expect(KSUID.max.to_s).to eq(KSUID::MAX_STRING_ENCODED)
    end

    it 'correctly represents zero' do
      expected = '0' * 27

      string = KSUID.from_bytes([0] * 20).to_s

      expect(string).to eq(expected)
    end
  end
end
