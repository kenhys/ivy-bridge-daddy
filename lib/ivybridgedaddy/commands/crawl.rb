# coding: utf-8
# frozen_string_literal: true

require "selenium-webdriver"

require_relative '../command'
require_relative '../config'
require_relative '../dbutil'
require_relative '../pckoubou'

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
        @crawler = ::IvyBridgeDaddy::Crawler::PcKoubou.new
        case @site
        when "pckoubou"
          case @task
          when "model"
            @crawler.update_models
          when "custom"
            @crawler.update_customs
          else
            if @task.start_with?("http")
              records = @models.select do |record|
                record.url =~ @task
              end
              model_urls = {}
              records.each do |record|
                model_urls[record._key] = record.url
              end
              @crawler.update_customs(model_urls)
            else
              @crawler.update_customs(@task)
            end
          end
        end
      end

    end
  end
end
