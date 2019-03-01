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
        [
          "A6-9500",
          "Celeron G4900",
          "Ryzen 3 2200G",
          "Ryzen 5 2400G",
          "Core i3-8100",
          "Core i5-8400",
          "Core i5-8500",
          "Core i5-9400F",
          "Core i7-8700",
          "Core i7-9700K",
          "Core i9-9900K",
        ].include?(text)
      end

      def memory?(text)
        [
          "4GBメモリ",
          "8GBメモリ"
        ].include?(text)
      end

      def storage?(text)
        [
          "240GB SSD",
          "256GB SSD",
          "240GB SSD＋1TB HDD",
          "1TB HDD"
        ].include?(text)
      end

      def graphic?(text)
        [
          "Radeon Vega8",
          "Radeon RX Vega11",
          "Radeon R7",
          "インテル UHD610",
          "インテル UHD630",
          "インテル UHDグラフィックス630",
          "GeForce GT1030",
          "GeForce GTX1050Ti",
          "GeForce GTX1060 3GB",
        ].include?(text)
      end

      def drive?(text)
        [
          "DVDスーパーマルチドライブ",
        ].include?(text)
      end

      def os?(text)
        [
          "Windows 10 Home",
          "Windows 10 Pro",
        ].include?(text)
      end

    end
  end
end
