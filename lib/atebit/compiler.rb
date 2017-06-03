require 'frequency'

class Atebit
class Compiler
  def self.compile(source)
    new(source).send(:result)
  end

  private

  attr_reader :source, :volume, :bpm

  def initialize(source)
    @source = source
    @volume = 0.8
    @bpm = 120.8
  end

  def result
    if source.nil? || source.strip.empty?
      return Resonad.Failure("Where's the song, bruh?")
    end

    Resonad.Success(source)
    Resonad.rescuing_from(Atebit::Compiler::Error) do
      parse
    end.map_error(&:message)
  end

  def parse
    source.each_line.flat_map{ |line| parse_line(line.strip) }
  end

  def parse_line(line)
    case line[0]
    when '!' then parse_directive(line)
    when nil, '#' then [] # empty line or comment
    else parse_notes(line)
    end
  end

  def parse_directive(line)
    var, value = line[1..-1].split.map(&:strip)
    case var && var.downcase
    when 'volume' then volume_directive(value)
    when 'bpm' then bpm_directive(value)
    when 'type' then type_directive(value)
    else fail!("Unrecognised directive: #{line}")
    end
  end

  def volume_directive(new_volume)
    @volume = Float(new_volume) / 100.0
    []
  rescue ArgumentError, TypeError
    fail!("Not a valid volume: #{new_volume}")
  end

  def bpm_directive(new_bpm)
    @bpm = Float(new_bpm)
    []
  rescue ArgumentError, TypeError
    fail!("Not a valid BPM: #{new_bpm}")
  end

  VALID_WAVE_TYPES = ['sine', 'square', 'saw', 'noise']
  def type_directive(new_type)
    if VALID_WAVE_TYPES.include?(new_type)
      [Instr[:set_type, new_type.to_sym]]
    else
      fail!("Invalid wave type: #{new_type}")
    end
  end

  def parse_notes(line)
    line.split.flat_map do |note|
      case note
      when '-' then rest_instrs
      else note_instrs(note)
      end
    end
  end

  def rest_instrs
    set_vol(0) + [gen_16th]
  end

  def note_instrs(note)
    freq = begin
      Frequency.for(note)
    rescue ArgumentError => ex
      fail!(ex.message)
    end

    set_vol(volume) + set_freq(freq) + [gen_16th]
  end

  def gen_16th
    Instr[:gen_samples, seconds_per_16th]
  end

  def set_vol(new_vol)
    new_vol = Float(new_vol)

    if new_vol != @last_volume
      @last_volume = new_vol
      Array[Instr[:set_vol, new_vol**2]]
    else
      []
    end
  end

  def set_freq(new_freq)
    new_freq = Float(new_freq)

    if new_freq != @last_frequency
      @last_frequency = new_freq
      Array[Instr[:set_freq, new_freq]]
    else
      []
    end
  end

  def seconds_per_16th
    seconds_per_beat = 60.0 / @bpm
    seconds_per_16th = seconds_per_beat / 4.0
  end

  def fail!(message)
    raise Atebit::Compiler::Error.new(message)
  end

  class Error < StandardError; end

  Instr = Struct.new(:type, :args) do
    def self.[](*args)
      new(*args)
    end

    def pretty_print(pp)
      other = ([type] + Array(args))
      other.pretty_print(pp)
    end
  end
end
end
