# coding: utf-8
# frozen_string_literal: true

require "thor"
require_relative '../../command'
require_relative '../../config'
require_relative '../../dbutil'

module IvyBridgeDaddy
  module Commands
    class Database < Thor
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
              table.integer("rank")
            end
            schema.create_table("CpuRanks", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Memories", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Storages", options = {:type => :patricia_trie}) do |table|
              table.integer("type")
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
              table.reference("maker", "Makers")
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
              table.boolean("end_sale")
              table.time("created_at")
              table.time("updated_at")
            end
            schema.create_table("Options", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("Prices", options = {:type => :patricia_trie}) do |table|
            end

            schema.create_table("MemoryChips", options = {:type => :patricia_trie}) do |table|
            end
            schema.create_table("MemoryModules", options = {:type => :patricia_trie}) do |table|
            end

            schema.change_table("Memories") do |table|
              table.reference("model", "Models")
              table.reference("chip", "MemoryChips")
              table.reference("module", "MemoryModules")
              table.integer("module_size")
              table.integer("module_count")
              table.integer("module_total")
              table.integer("price")
            end

            schema.create_table("Specs", options = {:type => :patricia_trie}) do |table|
              table.reference("model", "Models")
              table.reference("cpu", "Cpus")
              table.reference("memory", "Memories")
              table.integer("price")
              table.time("created_at")
              table.time("updated_at")
            end
          end

          @makers = Groonga["Makers"]
          data = {
            "pckoubou" => {
              "パソコン工房" => "https://www.pc-koubou.jp/",
            },
            "dospara" => {
              "ドスパラ" => "https://www.dospara.co.jp/"
            }
          }
          data.keys.each do |maker|
            print "Initialize database for #{maker} "
            data[maker].each do |key, value|
              puts "#{key}: #{value}"
              @makers[maker] = {
                name: key,
                url: value
              }
            end
          end
          @cpus = Groonga["Cpus"]
          data = {
            "Celeron G4900" => 452,
            "Core i7-3770" => 162,
            "Ryzen 5 2400G" => 130,
            "Ryzen 3 2200G" => 96,
            "Core i3-8100" => 86,
            "Core i5-8400" => 46,
            "Core i7-8700" => 25,
            "Core i5-9600K" => 24,
            "Core i7-9700K" => 12,
          }
          data.each do |key,value|
            @cpus[key] = {
              rank: value
            }
          end

        end
      end
    end
  end
end
