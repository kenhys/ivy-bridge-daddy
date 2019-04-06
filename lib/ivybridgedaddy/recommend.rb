require "rroonga"
require "tty-table"

module IvyBridgeDaddy
  module Crawler
    class Recommender
      def initialize
        @context = Groonga::Context.default
        @specs = Groonga["Specs"]
      end

      def recommend
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
