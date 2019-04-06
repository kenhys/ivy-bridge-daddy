# frozen_string_literal: true

require_relative '../command'

module Ivybridgedaddy
  module Commands
    class Recommend < Ivybridgedaddy::Command
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
