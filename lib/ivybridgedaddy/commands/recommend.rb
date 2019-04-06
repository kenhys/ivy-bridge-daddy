# frozen_string_literal: true

require_relative '../command'
require_relative '../config'
require_relative '../dbutil'
require_relative '../recommend'

module IvyBridgeDaddy
  module Commands
    class Recommend < IvyBridgeDaddy::Command
      def initialize(option, options)
        @option = option
        @options = options
        @config = ::IvyBridgeDaddy::Config.new
        IvyBridgeDaddy::DatabaseUtility.create_or_open_database(@config.database_path)
        @specs = Groonga["Specs"]
        @context = Groonga::Context.default
      end

      def execute(input: $stdin, output: $stdout)
        recommender = IvyBridgeDaddy::Crawler::Recommender.new
        recommender.recommend
      end
    end
  end
end
