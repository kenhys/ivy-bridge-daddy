# coding: utf-8
# frozen_string_literal: true

require "selenium-webdriver"

require_relative '../command'
require_relative '../config'
require_relative '../dbutil'
require_relative '../pckoubou'
require_relative '../dospara'

module IvyBridgeDaddy
  module Commands
    class Crawl < IvyBridgeDaddy::Command
      def initialize(site, task=nil, options)
        @site = site
        @task = task
        @options = options
        @config = ::IvyBridgeDaddy::Config.new
        IvyBridgeDaddy::DatabaseUtility.create_or_open_database(@config.database_path)
        @models = Groonga["Models"]
      end

      def execute(input: $stdin, output: $stdout)
        p @site
        case @site
        when "pckoubou"
          @crawler = ::IvyBridgeDaddy::Crawler::PcKoubou.new
          case @task
          when "model"
            @crawler.update_models
          when "custom"
            @crawler.update_customs
          else
            if @task.start_with?("http")
              @crawler.update_customs(model_urls(@task))
            else
              @crawler.update_customs(@task)
            end
          end
        when "dospara"
          @crawler = ::IvyBridgeDaddy::Crawler::Dospara.new
          case @task
          when "basic-model", "basic"
            @crawler.update_basic_models
          when "high-end-model", "highend"
            @crawler.update_high_end_models
          when "all-round-model", "allround"
            @crawler.update_all_round_models
          when "custom"
            @crawler.update_customs
          else
            if @task.start_with?("http")
              @crawler.update_customs(model_urls(@task))
            end
          end
        end
      end

      private

      def model_urls(url)
        records = @models.select do |record|
          record.url =~ url
        end
        model_urls = {}
        records.each do |record|
          model_urls[record._key] = record.url
        end
        model_urls
      end

    end
  end
end
