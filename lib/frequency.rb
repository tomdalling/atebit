module Frequency
  extend self

  A4_FREQUENCY = 440.0 # hz
  HALF_STEPS = %w(a a# b c c# d d# e f f# g g#)
  REGEX = /([a-g]#?)([0-9])?/
  TWELFTH_ROOT_2 = 2.0 ** (1.0/12.0)

  def for(note)
    match = REGEX.match(note)
    half_step = match && HALF_STEPS.index(match[1])
    if match.nil? || half_step.nil?
      raise ArgumentError, "Invalid note: #{note}"
    end

    octave = Integer(match[2] || '4', 10)

    diff = 12*(octave - 4) + half_step

    A4_FREQUENCY * (TWELFTH_ROOT_2 ** diff)
  end
end
