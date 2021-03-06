# coding: utf-8
require_relative "./crawler"

module IvyBridgeDaddy
  module Crawler
    class PcKoubou < BaseCrawler

      STORAGE_SET_M2SSD_HDD = 5
      STORAGE_SET_M2SSD = 4
      STORAGE_SET_SSD_HDD = 3
      STORAGE_SET_SSD = 2
      STORAGE_SET_HDD = 1

      def initialize
        @models = Groonga["Models"]
        @memories = Groonga["Memories"]
        @specs = Groonga["Specs"]
        options = Selenium::WebDriver::Firefox::Options.new
        #options.add_argument('-headless')

        @client = Selenium::WebDriver::Remote::Http::Default.new
        @client.read_timeout = 120
        @client.open_timeout = 120

        @driver = Selenium::WebDriver.for :firefox, :http_client => @client, options: options 
        @wait = Selenium::WebDriver::Wait.new(:timeout => 60)

      end

      def update_models
        @driver.navigate.to "https://www.pc-koubou.jp/pc/osless_desktop.php?pre=cmm_lde_205"

        next_page = true
        while next_page
          next_page = false
          @driver.find_elements(:class_name => "container-item").each do |item|
            model = ModelExtractor.new(item)
            specs = model.parse
            timestamp = Time.now
            data = {
              maker: "pckoubou",
              updated_at: timestamp
            }
            data[:created_at] = timestamp unless @models.key?(specs[:name])
            data.merge!(specs)
            p data
            @models[specs[:name]] = data
          end
          next_link = @driver.find_element(:class_name => "page-next")
          if next_link?(next_link)
            next_page = true
            next_link.click
          end
        end
      end

      def three_days_ago?(timestamp)
        Time.now - timestamp > 60 * 60 * 24 * 3
      end

      def update_customs(urls=nil)
        unless urls
          urls = {}
          records = @models.select do |record|
            record.maker == "pckoubou"
          end
          records.each do |record|
            if three_days_ago?(record.updated_at) and record.end_sale == false
              urls[record._key] = record.url
            end
          end
        end
        urls.each do |key, url|
          p url
          @driver.get(url)
          @wait.until do
            @driver.find_element(:class_name => "bto_spec_basic").displayed?
          end
          @driver.find_element(:class_name => "bto_spec_basic") do |spec_basic|
            spec_basic.find_elements(:tag_name => "div") do |spec|
              if spec.text.include?("DDR")
                specs = extract_memory_spec(spec.text)
                p specs
                if specs.empty?
                  p text
                  raise StandardError
                end
                if @memories = Groonga["Memories"]
                  data = {
                    model: key,
                  }
                  data.merge!(specs)
                  p key
                  p data
                  @memories[key] = data
                end
              end
            end
          end

          model = ""
          tab = @driver.find_element(:id => "tab-basic")
          title = tab.find_element(:xpath => "div/div/div[@class='bold']")
          model = title.text if title

          begin
          @wait.until do
            @driver.find_elements(:class_name => "p-custom")[0].displayed?
          end
          rescue NoMethodError
            button = @driver.find_element(:id => "item-sold-out")
            if button
              end_sale_by_url(url)
              next
            end
          end
          button = @driver.find_elements(:class_name => "p-custom")[0]
          button.click if button.displayed?
          @wait.until do
            @driver.find_element(:class_name => "product-config").displayed?
          end
          @wait.until do
            @driver.find_element(:class_name => "p-total-body").displayed?
          end
          total_body = @driver.find_element(:class_name => "p-total-body")
          total_price = extract_price(total_body.text)
          memory_id = nil
          @driver.find_elements(:class_name => "product-config").each do |product_config|
            h3 = product_config.find_element(:tag_name => "h3")
            if h3.text == "メインメモリ"
              memory_id = product_config.attribute("id")
            end
          end
          p memory_id
          product_config = @driver.find_element(:id => memory_id)
          input = product_config.find_element(:tag_name => "input")
          unless input.attribute("type") == "hidden"
            input.location_once_scrolled_into_view
          end
          labels = product_config.find_elements(:xpath => "div/dl/dd/ul/li/label")
          if labels.size > 0
            labels.each do |label|
              price = label.find_element(:tag_name => "input").attribute("data-price").to_i
              description = label.find_element(:class => "p-radio-name").text
              memory_specs = extract_memory_spec(description)
              update_specs_by_model(model, total_price, memory_specs)
            end
          else
            # no options
            label = product_config.find_element(:xpath => "div/dl/div/div[@class='p-fixed-name']")
            memory_specs = extract_memory_spec(label.text)
            update_specs_by_model(model, total_price, memory_specs)
          end
        end
      end

      def update_specs_by_model(model, base_price, memory_specs)
        if memory_specs.empty?
          p memory_specs
          raise StandardError
        end
        key = "#{model}_#{memory_specs[:module_total]}GB"
        data = {
          model: model,
          price: memory_specs[:price]
        }
        data.merge!(memory_specs)
        p data
        @memories[key] = data
        timestamp = Time.now
        spec = {
          model: model,
          memory: key,
          price: base_price + memory_specs[:price],
          updated_at: timestamp
        }
        p spec
        @specs[key] = spec
      end

      class ModelExtractor < self
        def initialize(element, output = nil)
          @output = output || @stdout
          @element = element
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
          specs[:code] = @element.find_element(:class_name => "item-code").text
          specs[:catch_phrase] = @element.find_element(:class_name => "item-detail").text
          # @element.find_element(:class_name => "product-name").text
          name = @element.find_element(:class_name => "product-review").find_element(:tag_name => "a").text
          specs[:name] = name
          details = @element.find_elements(:class_name => "item-detail")
          specs[:detail] = details[1].text
          p @element.find_elements(:class_name => "item-detail")[0].text
          p @element.find_elements(:class_name => "item-detail")[1].text
          specs[:url] = @element.find_element(:class_name => "product-review").find_element(:tag_name => "a").attribute("href")
          specs[:price] = extract_price(@element.find_element(:class_name => "price").text)
          @element.find_elements(:class_name => "item-detail")[1].find_elements(:class_name => "bto_spec").each do |spec|
            text = spec.text
            if cpu?(text)
              specs[:cpu] = text
            elsif memory?(text)
              specs[:memory] = text.sub(/\(.+?\)/, '')
            elsif storage?(text)
              text = text.sub(/Serial-ATA /, '')
              if text =~ /M\.2 SSD/
                text = text.sub(/NVMe対応 /, '')
              end
              specs[:storage] = text
              @storage = Groonga["Storages"]
              @storage[text] = {
                :type => to_storage_set(text)
              }
            elsif graphic?(text)
              specs[:graphic] = text.sub(/ Graphics/, '').strip
            elsif board?(text)
              specs[:board] = text.sub(/ Express/, '').strip
            elsif drive?(text)
              specs[:drive] = text
            elsif os?(text)
              specs[:os] = "OSなし"
            elsif formfactor?(text)
              specs[:formfactor] = text
            elsif power?(text)
              specs[:power] = text
            else
              next if name == "STYLE-I0B6-i5T-UHS [OS LESS]" and text == "160W"
              p "|#{spec.text}|"
              raise StandardError
            end
          end
          specs
        end

        def to_storage_set(text)
          if text.include?("M.2") and text.include?("HDD")
            STORAGE_SET_M2SSD_HDD
          elsif text.include?("M.2")
            STORAGE_SET_M2SSD
          elsif text.include?("SSD") and text.include?("HDD")
            STORAGE_SET_SSD_HDD
          elsif text.include?("SSD")
            STORAGE_SET_SSD
          else
            STORAGE_SET_HDD
          end
        end
      end

      private
      def next_link?(tag)
        tag.tag_name == "a"
      end

      def extract_price(text)
        text.sub(/円\(税別\) ～/, '').sub(',', '').to_i
      end

      def memory?(text)
        [
          "4GB(4GB×1)",
          "8GB(4GB×2)",
          "8GB(8GB×1)",
          "16GB(8GB×2)",
        ].include?(text)
      end

      def board?(text)
        text.include?("AMD") or
          text.include?("Express")
      end

      def formfactor?(text)
        text.include?("microATX") or
          text.include?("Mini-ITX") or
          text.include?("タワー") or
          text.include?("ミニタワー") or
          text.include?("スリムタイプ") or
          text.include?("ミドルタワー")
      end

      def extract_memory_spec(text)
        specs = {}
        if text =~ /(DDR.+?) \((.+?)\) (\d.+?)GB\((\d.+?)×(.+)\)$/
          specs = {
            chip: $1,
            module: $2,
            module_total: $3.to_i,
            module_size: $4.to_i,
            module_count: $5.to_i
          }
        elsif text =~ /(DDR.+?) (\d+?)GB×(\d)\(.+\/計(\d+)GB\).+\[(.+)円\]/
          specs = {
            chip: $1,
            module: to_memory_module($1),
            module_size: $2.to_i,
            module_count: $3.to_i,
            module_total: $4.to_i,
            price: $5.sub(/,/, '').to_i
          }
        elsif text =~ /(DDR.+?) (\d+?)GB×(\d)\(計(\d)GB\).+\[(.+)円\]/
          specs = {
            chip: $1,
            module: to_memory_module($1),
            module_size: $2.to_i,
            module_count: $3.to_i,
            module_total: $4.to_i,
            price: $5.sub(/,/, '').to_i
          }
        end
        specs
      end

      def extract_model_spec(item)
      end

      def end_sale_by_url(url)
        dataset = @models.select do |record|
          record.url == url
        end
        dataset.each do |record|
          record.end_sale = true
        end
      end
    end
  end
end
