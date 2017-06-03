require 'oscillator'
require 'wavefile'
require 'stringio'

class Atebit
class VM
  attr_reader :oscillator, :samples

  def initialize
    @oscillator = Oscillator.new
    @samples = []
  end

  def execute_all(instructions)
    instructions.each { |instr| execute(instr) }
  end

  def execute(instr)
    case instr.type
    when :set_type then oscillator.wave_type = instr.args
    when :set_freq then oscillator.frequency = instr.args
    when :set_vol then oscillator.amplitude = instr.args
    when :gen_samples then generate_samples(instr.args)
    end

    nil
  end

  def generate_samples(duration_seconds)
    sample_count = Integer(duration_seconds * oscillator.sample_rate)
    new_samples = oscillator.generate(sample_count)
    samples.concat(new_samples)
  end

  def wavefile
    osc_format = WaveFile::Format.new(:mono, :float, oscillator.sample_rate)
    output_format = WaveFile::Format.new(:mono, :pcm_8, oscillator.sample_rate)
    output = StringIO.new
    WaveFile::Writer.new(output, output_format) do |writer|
      buffer = WaveFile::Buffer.new(samples, osc_format)
      writer.write(buffer)
    end
    output.string
  end
end
end
