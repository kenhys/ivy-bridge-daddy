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
                                  :filter => "memory.module_total >= 16 && model.storage.type >= 3",
                                  :output_columns => "_key,_score,model,price,memory.module_total,model.storage,model.cpu",
                                  :sort_keys => "_score,price",
                                  :limit => -1)
        header = ["score", "price", "model", "cpu", "memory", "storage"]
        table = []
        records.each do |record|
          entry = [
            record["_score"],
            record.price,
            record.model,
            record["model.cpu"],
            record["memory.module_total"],
            record["model.storage"]
          ]
          table << entry
        end
        puts TTY::Table.new(header, table).render(:unicode, alignment: [:right])
      end      
    end
  end
end
