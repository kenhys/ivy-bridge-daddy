# frozen_string_literal: true

require_relative '../command'

module IvyBridgeDaddy
  module Commands
    class Recommend < IvyBridgeDaddy::Command
      def initialize(option, options)
        @option = option
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
