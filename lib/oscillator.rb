class Oscillator
  attr_reader :sample_rate
  attr_accessor :frequency, :amplitude, :wave_type

  def initialize
    @frequency = 261.6 # C4
    @amplitude = 0.8
    @phase = 0.0
    @sample_rate = 44100 #hz
    @wave_type = :square
  end

  def generate(num_samples)
    Integer(num_samples).times.map do
      step
    end
  end

  def step
    secs = 1.0/sample_rate
    period = 1.0/frequency

    @phase += secs/period
    @phase -= 1.0 if @phase > 1.0

    amplitude * wave_sample
  end

  def wave_sample
    case wave_type
    when :saw then 2.0*@phase - 1.0
    when :square then (@phase > 0.5 ? 1.0 : -1.0)
    when :sine then Math.sin(2.0 * Math::PI * @phase)
    when :noise then 2.0*rand - 1.0
    else fail "Unrecognised wave type: #{wave_type.inspect}"
    end
  end
end
