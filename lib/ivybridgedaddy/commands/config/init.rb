# frozen_string_literal: true

require_relative '../../command'

module IvyBridgeDaddy
  module Commands
    class Config
      class Init < IvyBridgeDaddy::Command
        def initialize(path=nil, options)
          @path = path
          @options = options
        end

        def execute(input: $stdin, output: $stdout)
          # Command logic goes here ...
          output.puts "OK"
        end
      end
    end
  end
end
