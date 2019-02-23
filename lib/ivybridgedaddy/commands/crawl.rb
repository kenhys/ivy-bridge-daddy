# frozen_string_literal: true

require_relative '../command'

module IvyBridgeDaddy
  module Commands
    class Crawl < IvyBridgeDaddy::Command
      def initialize(site, task=nil, options)
        @site = site
        @task = task
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "OK"
      end
    end
  end
end
