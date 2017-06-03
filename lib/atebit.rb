require 'pp'

class Atebit < Roda
  plugin :render, engine: 'html.slim'

  route do |r|
    r.root do
      @example_song = File.read('example.txt')
      view :home
    end

    r.post 'generate' do
      result = Compiler.compile(r.params['song'])
      if result.ok?
        vm = VM.new
        vm.execute_all(result.value)
        response['Content-Disposition'] = 'attachment; filename="atebit.wav"'
        vm.wavefile
      else
        'ERROR: ' + result.error.to_s
      end
    end
  end
end

require 'atebit/compiler'
require 'atebit/vm'
