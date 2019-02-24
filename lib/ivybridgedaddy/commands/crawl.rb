# coding: utf-8
# frozen_string_literal: true

require "selenium-webdriver"

require_relative '../command'
require_relative '../config'
require_relative '../dbutil'

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
        # Command logic goes here ...
        case @site
        when "pckoubou-model"
          @crawler = PcKoubouCrawler.new
          @crawler.update_models
        end
      end

      class PcKoubouCrawler
        def initialize
          options = Selenium::WebDriver::Firefox::Options.new
          #options.add_argument('-headless')

          @driver = Selenium::WebDriver.for :firefox, options: options
        end

        def update_models
          @driver.navigate.to "https://www.pc-koubou.jp/pc/osless_desktop.php?pre=cmm_lde_205"

          next_page = true
          while next_page
            @driver.find_elements(:class_name => "container-item").each do |item|
              code = item.find_element(:class_name => "item-code").text
              catch_phrase = item.find_element(:class_name => "item-detail").text
              # item.find_element(:class_name => "product-name").text
              name = item.find_element(:class_name => "item-name").text
              detail = item.find_elements(:class_name => "item-detail")
              p item.find_elements(:class_name => "item-detail")[0].text
              p item.find_elements(:class_name => "item-detail")[1].text
              url = item.find_element(:class_name => "product-review").find_element(:tag_name => "a").attribute("href")
              price_label = item.find_element(:class_name => "price").text
              price = price_label.sub(/円\(税別\) ～/, '').sub(',', '').to_i
              cpu = ""
              memory = ""
              storage = ""
              graphic = ""
              board = ""
              drive = ""
              os = ""
              formfactor = ""
              power = ""
              item.find_elements(:class_name => "item-detail")[1].find_elements(:class_name => "bto_spec").each do |spec|
                text = spec.text
                if cpu?(text)
                  cpu = text
                elsif memory?(text)
                  memory = text
                elsif storage?(text)
                  storage = text
                elsif graphic?(text)
                  graphic = text
                elsif board?(text)
                  board = text
                elsif drive?(text)
                  drive = text
                elsif os?(text)
                  os = text
                elsif formfactor?(text)
                  formfactor = text
                elsif power?(text)
                  power = text
                else
                  p "|#{spec.text}|"
                  raise StandardError
                end
              end
              timestamp = Time.now
              data = {
                url: url,
                code: code,
                catch_phrase: catch_phrase,
                name: name,
                detail: detail[1].text,
                price: price,
                cpu: cpu,
                memory: memory,
                storage: storage,
                graphic: graphic,
                board: board,
                drive: drive,
                os: os,
                formfactor: formfactor,
                power: power,
                created_at: timestamp,
                updated_at: timestamp
              }
              p data
              @models[name] = data
            end
            next_link = driver.find_element(:class_name => "page-next")
            if next_link.tag_name == "a"
              next_link.click
            else
              next_page = false
            end
          end
        end

        def update_customs
        end

        private
        def cpu?(text)
          [
            "Athlon 200GE",
            "A6-9500",
            "Celeron G4900",
            "Ryzen 3 2200G",
            "Ryzen 5 2400G",
            "Core i3-8100",
            "Core i5-8400",
            "Core i5-9600K",
            "Core i7-8700",
            "Core i7-9700K",
          ].include?(text)
        end

        def memory?(text)
          [
            "4GB(4GB×1)",
            "8GB(4GB×2)",
            "8GB(8GB×1)",
            "16GB(8GB×2)",
          ].include?(text)
        end

        def storage?(text)
          [
            "120GB Serial-ATA SSD",
            "240GB Serial-ATA SSD",
            "1TB Serial-ATA HDD",
            "2TB Serial-ATA HDD",
            "250GB ⇒ 512GB [インテル SSD 660p] NVMe対応 M.2 SSD ※0円アップグレード",
          ].include?(text)
        end

        def graphic?(text)
          [
            "Radeon Vega 3 Graphics",
            "Radeon Vega 8 Graphics",
            "Radeon RX Vega 11 Graphics",
            "Radeon R5 Graphics",
            "UHD Graphics 610",
            "UHD Graphics 630",
            "GeForce GTX 1060 6GB GDDR5",
            "GeForce GTX 1050 2GB GDDR5",
            "GeForce GTX 1060 3GB GDDR5",
            "GeForce RTX 2070 8GB GDDR6",
            "GeForce RTX 2080 Ti 11GB GDDR6",
          ].include?(text)
        end

        def board?(text)
          [
            "AMD B350",
            "インテル B360 Express",
            "インテル Z390 Express",
          ].include?(text)
        end

        def drive?(text)
          [
            "DVDスーパーマルチ",
          ].include?(text)
        end

        def os?(text)
          text.start_with?("OSなし")
        end

        def formfactor?(text)
          [
            "microATX",
            "タワー / microATX",
            "ミニタワー / microATX",
            "スリムタイプ / microATX",
            "ミドルタワー / ATX",
          ].include?(text)
        end

        def power?(text)
          [
            "350W 80PLUS BRONZE認証 ATX電源",
            "300W 80PLUS BRONZE認証 TFX電源",
            "500W 80PLUS BRONZE認証 ATX電源",
            "450W 80PLUS STANDARD認証 ATX電源",
            "700W 80PLUS BRONZE認証 ATX電源",
          ].include?(text)
        end
      end
    end
  end
end
