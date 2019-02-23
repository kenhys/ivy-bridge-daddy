# frozen_string_literal: true

require_relative '../command'

module Ivybridgedaddy
  module Commands
    class Crawl < IvyBridgeDaddy::Command
      def initialize(site,option, options)
        @site,option = site,option
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
