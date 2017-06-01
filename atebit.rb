require 'wavefile'

module Frequency
  extend self

  A4 = 440.0
  HALF_STEPS = %w(a a# b c c# d d# e f f# g g#)
  REGEX = /([a-g]#?)([0-9])?/
  TWELFTH_ROOT_2 = 2.0 ** (1.0/12.0)

  def for(note)
    match = REGEX.match(note)
    raise ArgumentError("Invalid note: #{note}") unless match

    half_step = HALF_STEPS.index(match[1])
    octave = Integer(match[2] || '4')

    diff = 12*(octave - 4) + half_step

    A4 * (TWELFTH_ROOT_2 ** diff)
  end
end

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

class Controller
  attr_reader :oscillator

  def initialize(oscillator)
    @oscillator = oscillator
    @bpm = 60.0
  end

  def apply_command(command)
    return [] if command.start_with?('#')

    if command.start_with?('!')
      pragma(command)
      []
    else
      command.split.flat_map do |note|
        if note == '-'
          [0.0] * samples_per_sixteenth
        else
          oscillator.frequency = Frequency.for(note)
          generate_note
        end
      end
    end
  end

  private

    def generate_note
      oscillator.generate(samples_per_sixteenth)
    end

    def pragma(line)
      var, value = line[1..-1].split.map(&:strip)
      case var
      when 'bpm' then @bpm = Float(value)
      when 'type' then oscillator.wave_type = value.to_sym
      when 'volume' then oscillator.amplitude = (Float(value) / 100.0) ** 2
      else fail "Unhandled pragma: #{line}"
      end
    end

    def samples_per_sixteenth
      spb = 60.0 / @bpm
      Integer(0.25 * spb * oscillator.sample_rate)
    end
end

osc = Oscillator.new
controller = Controller.new(osc)
format = WaveFile::Format.new(:mono, :float, osc.sample_rate)

WaveFile::Writer.new('output.wav', format) do |writer|
  File.read('example.txt').each_line do |line|
    samples = controller.apply_command(line)
    buffer = WaveFile::Buffer.new(samples, format)
    writer.write(buffer)
  end
end
`play output.wav`
