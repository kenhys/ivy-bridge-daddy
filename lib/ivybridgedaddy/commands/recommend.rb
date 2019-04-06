# frozen_string_literal: true

require_relative '../command'
require_relative '../config'
require_relative '../dbutil'

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
        # Command logic goes here ...
        records = @context.select(@specs,
                                  :filter => "memory.module_total >= 16 ",
                                  :output_columns => "_key,_score,model,price,memory.module_total,model.storage",
                                  :sort_keys => "_score,price",
                                  :limit => -1)
        records.each do |record|
          entry = "%d %s %s %s %s" % [
                 record["_score"],
                 record.price,
                 record.model,
                 record["memory.module_total"],
                 record["model.storage"]
          ]
          puts entry
        end
      end
    end
  end
end
