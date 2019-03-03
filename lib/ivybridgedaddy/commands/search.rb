# frozen_string_literal: true

require_relative '../command'

module IvyBridgeDaddy
  module Commands
    class Search < IvyBridgeDaddy::Command
      def initialize(query, options)
        @query = query
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
