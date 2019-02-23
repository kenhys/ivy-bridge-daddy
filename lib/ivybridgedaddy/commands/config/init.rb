# frozen_string_literal: true

require_relative '../../command'

module Ivybridgedaddy
  module Commands
    class Config
      class Init < Ivybridgedaddy::Command
        def initialize(path, options)
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
