# coding: utf-8
require_relative "./crawler"

module IvyBridgeDaddy
  module Crawler
    class Dospara < BaseCrawler
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
        @driver.navigate.to basic_model_url
        update_models
      end

      def update_high_end_models
        @driver.navigate.to high_end_model_url
        update_models
      end

      def update_all_round_models
        @driver.navigate.to all_round_model_url
        update_models
      end

      def update_customs(urls=nil)
        urls ||= custom_urls
        urls.each do |key, url|
          p url
          @driver.get(url)
          begin
            @wait.until do
              @driver.find_element(:class_name => "tabNav").displayed?
            end
            navigation = @driver.find_element(:class_name => "tabNav").find_elements(:tag_name => "li")[1].find_element(:tag_name => "a")
            navigation.click
            spec_table = @driver.find_element(:id => "specdata")
            extractor = ModelDetailExtractor.new(spec_table)
            specs = extractor.parse
            p specs
            input = @driver.find_element(:id => "configChangeBtnBox").find_element(:tag_name => "input")
            input.location_once_scrolled_into_view
            input.click
            custom = ModelCustomExtractor.new(@driver)
            memory_specs = custom.parse_memory_spec
            basic_price = custom.parse_basic_price
            memory_specs.each do |memory_spec|
              model = find_model_by_url(url)
              memory_spec[:model] = model
              key = "#{model}_#{memory_spec[:module_total]}GB"
              p memory_spec
              @memories[key] = memory_spec
              timestamp = Time.now
              data = {
                model: model,
                price: basic_price + memory_spec[:price],
                memory: key,
                updated_at: timestamp
              }
              data[:created_at] = timestamp unless @specs.key?(key)
              p data
              @specs[key] = data
            end
          rescue Selenium::WebDriver::Error::NoSuchElementError
            end_sale_by_url(url)
          rescue Selenium::WebDriver::Error::TimeOutError
            @driver.find_element(:id => "endSaleWrapper") do |div|
              if div.text =~ /販売を終了いたしました/
                end_sale_by_url(url)
              end
            end
          end
        end
      end

      private
      def basic_model_url
        "https://www.dospara.co.jp/5shopping/search.php?tg=2&tc=531"
      end

      def high_end_model_url
        "https://www.dospara.co.jp/5shopping/search.php?tg=2&tc=529"
      end

      def all_round_model_url
        "https://www.dospara.co.jp/5shopping/search.php?tg=2&tc=530"
      end

      def find_model_by_url(url)
        records = @models.select do |record|
          record.url =~ url
        end
        model = ""
        records.each do |record|
          model = record["_key"]
        end
        model
      end

      def update_models
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
              catch_phrase: model,
              url: url,
              detail: tbody.text,
              updated_at: timestamp,
              price: price
            }
            data[:created_at] = timestamp unless @models.key?(model)
            data.merge!(specs)
            p data
            @models[model] = data
          end
        end
      end

      def custom_urls
        urls = {}
        records = @models.select do |record|
          record.maker == "dospara" and
          record.end_sale == false
        end
        records.each do |record|
          if outdated?(record)
            urls[record._key] = record.url
          end
        end
        urls
      end

      def outdated?(record)
        Time.now - record["updated_at"] > 60 * 30
      end

      def end_sale_by_url(url)
        dataset = @models.select do |record|
          record.url == url
        end
        dataset.each do |record|
          record.end_sale = true
        end
      end

      def extract_model_name(text)
        text.sub(/（.+）/, '').strip
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
            specs[:memory] = text.sub(/メモリ/, '')
          elsif storage?(text)
            specs[:storage] = text
          elsif graphic?(text)
            case text
            when "インテル UHDグラフィックス630",
              specs[:graphic] = "UHD 630"
            else
              text.sub!(/インテル /, "")
              text.sub!(/Vega(\d+)/, 'Vega \1')
              text.sub!(/UHD/, "UHD ")
              specs[:graphic] = text.strip
            end
          elsif drive?(text)
            case text
            when "光学ドライブ無し"
              specs[:drive] = "なし"
            else
              specs[:drive] = text.sub(/ドライブ/, '')
            end
          end
        end
        specs
      end

      def extract_model_detail_spec(spec_table)
        specs = {}
        spec_table.find_elements(:tag_name => "tr").each do |tr|
          th = tr.find_element(:tag_name => "th")
          td = tr.find_element(:tag_name => "td")
          title = th.text
          case title
          when "OS"
            specs[:os] = td.text.sub(/ 64ビット/, '')
          when "CPU"
            if td.text =~ /.+(Core.+)\s\(.+/
              specs[:cpu] = $1
            else
              p td.text
              raise StandardError
            end
          when "グラフィック"
            case td.text
            when "インテル UHDグラフィックス630 (CPU内蔵)"
              specs[:graphic] = "UHD 630"
            else
              p td.text
              raise StandardError
            end
          when "メモリ"
            #8GB DDR4 SDRAM(PC4-21300/8GBx1)
          when "ハードディスク"
          when "SSD"
            specs[:storage] = td.text
          when "光学ドライブ"
            specs[:drive] = "DVDスーパーマルチ" if td.text.include?("DVDスーパーマルチ")
          when "マザーボード"
            specs[:board] = "DVDスーパーマルチ" if td.text.include?("チップセット")
          else
            raise StandardError
          end
        end
        specs
      end

      def extract_price(text)
        text.sub(/,/, '').sub(/円\(\+税\)/, '').sub(',', '').to_i
      end

      def memory?(text)
        text.include?("メモリ")
      end

      class ModelCustomExtractor < self
        def initialize(driver, output = nil)
          @output = output || @stdout
          @driver = driver
          @wait = Selenium::WebDriver::Wait.new(:timeout => 20)
        end

        def parse_memory_spec
          specs = []
          memory_customize_id = "contentitem_cus_0000000184"
          @wait.until do
            @driver.find_element(:id => memory_customize_id).displayed?
          end
          table = @driver.find_element(:id => memory_customize_id).find_element(:class_name => "c-parts-table")
          table.find_elements(:tag_name  => "tr").each do |tr|
            cell_title = tr.find_element(:class_name => "cell-title").text
            cell_price = tr.find_element(:class_name => "cell-price").text
            memory_specs = extract_memory_spec(cell_title)
            memory_specs[:price] = extract_price(cell_price)
            specs << memory_specs
          end
          specs
        end

        def parse_basic_price
          id = "totalamt2"
          @wait.until do
            @driver.find_element(:id => id).displayed?
          end
          price_label = @driver.find_element(:id => id).text
          price_label.sub(/,/, '').to_i
        end

        private
        def extract_memory_spec(text)
          specs = {}
          if text =~ /(.+)GB (DDR4.+)\((PC4.+)\/(\d+)GBx(\d)(\/.+)?\)/
            specs = {
              chip: to_memory_chip($3),
              module: $3,
              module_size: $4.to_i,
              module_count: $5.to_i,
              module_total: $1.to_i
            }
          end
          specs
        end

        def extract_price(text)
          price = 0
          text = text.sub(/,/, '')
          if text =~ /\+(\d+)円\(\+税\)/
            price = $1.to_i
          elsif text =~ /\-(\d+)円\(\+税\)/
            price = - $1.to_i
          end
          price
        end
      end

      class ModelDetailExtractor < self
        def initialize(table, output = nil)
          @output = output || @stdout
          @table = table
        end

        def parse
          specs = {
            cpu: "",
            memory: "",
            storage: "",
            graphic: "",
            board: "",
            drive: "",
            os: "",
            formfactor: "",
            power: ""
          }
          caption = ""
          spec = ""
          @table.find_elements(:tag_name => "tr").each do |tr|
            begin
              th = tr.find_element(:tag_name => "th")
              caption = th.text
            rescue Selenium::WebDriver::Error::NoSuchElementError
            end
            begin
              td = tr.find_element(:tag_name => "td")
              spec = td.text
              case caption
              when "OS"
                specs[:os] = extract_os_spec(spec)
              when "CPU"
                specs[:cpu] = extract_cpu_spec(spec)
              when "グラフィック機能"
                specs[:graphic] = extract_graphic_spec(spec)
              when "メモリ"
                memory = extract_memory_spec(spec)
                specs[:memory] = "#{memory[:module_total]}GB"
              when "ハードディスク/SSD"
                specs[:storage] = spec
              when "SSD"
                specs[:storage] = spec
              when "光学ドライブ"
                specs[:drive] = extract_drive_spec(spec)
              when "マザーボード"
                specs[:board] = extract_board_spec(spec)
              when "電源"
                specs[:power] = spec
              end
            rescue Selenium::WebDriver::Error::NoSuchElementError
            end
          end
          p specs
        end

        def extract_os_spec(text)
          text.sub(/ 64ビット/, '')
        end

        def extract_cpu_spec(text)
          spec = text
          if text =~ /.+(Core.+)\s\(.+/
            spec = $1
          elsif text =~ /.+(Celeron.+)\s\(.+/
            spec = $1
          elsif text =~ /.+(Ryzen.+)\s\(.+/
            spec = $1
          elsif text =~ /AMD (.+)\s\(.+/
            spec = $1
          else
            p text
            raise StandardError
          end
          spec
        end

        def extract_graphic_spec(text)
          if text.include?("UHDグラフィックス630")
            "UHD 630"
          elsif text.include?("UHDグラフィックス610")
            "UHD 610"
          elsif text =~ /(.+)\s\(.+\)/
            $1
          else
            p text
            raise StandardError
          end
        end

        def extract_memory_spec(text)
          specs = {}
          if text =~ /(.+)GB (DDR4.+)\((PC4.+)\/(\d+)GBx(\d)/
            specs = {
              chip: to_memory_chip($1),
              module: $3,
              module_size: $4.to_i,
              module_count: $5.to_i,
              module_total: $1.to_i
            }
          end
          specs
        end

        def extract_board_spec(text)
          spec = ""
          if text =~ /インテル (.+) チップセット/
            spec = $1
          elsif text =~ /AMD (.+) チップセット/
            spec = $1
          else
            p text
            raise StandardError
          end
          spec
        end

        def extract_formfactor_spec(text)
          spec = ""
          if text =~ /.+ \((.*?ATX)\)/
            spec = $1
          else
            p text
            raise StandardError
          end
          spec
        end
      end
    end
  end
end
