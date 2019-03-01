# coding: utf-8
module IvyBridgeDaddy
  module Crawler
    class Dospara
      def initialize
        @models = Groonga["Models"]
        @memories = Groonga["Memories"]
        @specs = Groonga["Specs"]
        options = Selenium::WebDriver::Firefox::Options.new
        #options.add_argument('-headless')

        @driver = Selenium::WebDriver.for :firefox, options: options
        @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
      end

      def update_basic_models
        @driver.navigate.to "https://www.dospara.co.jp/5shopping/search.php?tg=2&tc=531"

        @driver.execute_script("TabOpen('list')")
        @driver.find_elements(:class_name => "itemSearchTable").each do |table|
          table.find_elements(:tag_name => "tbody").each do |tbody|
            url = tbody.find_element(:xpath => "tr/td/a").attribute("href")
            model = extract_model_name(tbody.find_element(:xpath => "tr/td/a").text)
            price = extract_price(tbody.find_element(:class => "price").text)
            specs = extract_model_spec(tbody)
            timestamp = Time.now
            p specs
            data = {
              maker: "dospara",
              name: model,
              url: url,
              created_at: timestamp,
              updated_at: timestamp,
              price: price
            }
            data.merge!(specs)
            p data
            @models[model] = data
          end
        end
      end

      private
      def extract_model_name(text)
        text.sub(/（.+）/, '')
      end

      def extract_model_spec(item)
        specs = {}
        item.find_elements(:xpath => "tr/td[@rowspan=2]").each do |td|
          text = td.text
          if os?(text)
            specs[:os] = text
          elsif cpu?(text)
            specs[:cpu] = td.text
          elsif memory?(text)
            specs[:memory] = text
          elsif storage?(text)
            specs[:storage] = text
          elsif graphic?(text)
            case text
            when "インテル UHDグラフィックス630",
              specs[:graphic] = "UHD630"
            else
              specs[:graphic] = text.sub(/インテル /, '')
            end
          elsif drive?(text)
            specs[:drive] = text
          end
        end
        specs
      end

      def extract_price(text)
        text.sub(/円\(\+税\)/, '').sub(',', '').to_i
      end

      def cpu?(text)
        text.start_with?("Ryzen") or
          text.start_with?("Celeron") or
          text.start_with?("Ryzen") or
          text.start_with?("A6")
      end

      def memory?(text)
        text.include?("メモリ")
      end

      def storage?(text)
        text.include?("SSD") or text.include?("HDD")
      end

      def graphic?(text)
        text.include?("Radeon") or
          text.include?("UHD") or
          text.include?("GeForce")
      end

      def drive?(text)
        text.include?("DVDスーパーマルチドライブ")
      end

      def os?(text)
        text.include?("Windows")
      end

    end
  end
end
