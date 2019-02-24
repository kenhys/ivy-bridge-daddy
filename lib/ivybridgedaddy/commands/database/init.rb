# frozen_string_literal: true

require_relative '../../command'
require_relative '../../config'
require_relative '../../dbutil'

module IvyBridgeDaddy
  module Commands
    class Database
      class Init < IvyBridgeDaddy::Command
        def initialize(path, options)
          @path = path
          @options = options
          @config = ::IvyBridgeDaddy::Config.new
          IvyBridgeDaddy::DatabaseUtility.create_or_open_database(@config.database_path)
        end

        def execute(input: $stdin, output: $stdout)
          Groonga::Schema.define do |schema|
            schema.create_table("Makers", options = {:type => :patricia_trie}) do |table|
              table.text("name")
              table.text("url")
            end

            schema.create_table("Cpus", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Memories", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Storages", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Graphics", options = {:type => :patricia_trie}) do |table|
            end

            schema.create_table("Boards", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Drives", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("OperatingSystems", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("FormFactors", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Powers", options = {:type => :patricia_trie}) do |table|
            end

            schema.create_table("Models", options = {:type => :patricia_trie}) do |table|
              table.text("code")
              table.text("catch_phrase")
              table.text("name")
              table.text("detail")
              table.text("url")
              table.integer("price")
              table.reference("cpu", "Cpus")
              table.reference("memory", "Memories")
              table.reference("storage", "Storages")
              table.reference("graphic", "Graphics")
              table.reference("board", "Boards")
              table.reference("drive", "Drives")
              table.reference("os", "OperatingSystems")
              table.reference("formfactor", "FormFactors")
              table.reference("power", "Powers")
              table.time("created_at")
              table.time("updated_at")
            end
            schema.create_table("Options", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Prices", options = {:type => :patricia_trie}) do |table|
            end

            schema.create_table("Specs", options = {:type => :patricia_trie}) do |table|
              table.reference("model", "Models")
              table.reference("cpu", "Cpus")
              table.reference("memory", "Memories")
              table.time("created_at")
              table.time("updated_at")
            end

          end

        end
      end
    end
  end
end
