#!/usr/bin/env ruby

require_relative '../lib/boot'

file = ARGV[0] || File.expand_path('../example.txt', __dir__)

compiled = Atebit::Compiler.compile(File.read(file))
raise compiled.error if compiled.bad?

vm = Atebit::VM.new
vm.execute_all(compiled.value)
File.write('tmp/output.wav', vm.wavefile)

begin
  `play tmp/output.wav`
ensure
  File.delete('tmp/output.wav')
end
