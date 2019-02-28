# coding: utf-8
module IvyBridgeDaddy
  module Crawler
    class PcKoubou
      def initialize
        @models = Groonga["Models"]
        @memories = Groonga["Memories"]
        @specs = Groonga["Specs"]
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
              maker: @site.downcase,
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

      def update_customs(urls=nil)
        unless urls
          records = @models.select do |record|
            record.maker == @site
          end
          records.each do |record|
            urls[record._key] = record.url
          end
        end
        wait = Selenium::WebDriver::Wait.new(:timeout => 20)
        urls.each do |key, url|
          p url
          @driver.get(url)
          wait.until do
            @driver.find_element(:class_name => "bto_spec_basic").displayed?
          end
          @driver.find_element(:class_name => "bto_spec_basic") do |spec_basic|
            spec_basic.find_elements(:tag_name => "div") do |spec|
              memory_spec = spec.text
              if memory_spec.start_with?("DDR")
                memory_spec =~ /\A(DDR.+?) \((.+?)\) (\d.+?)GB\((\d.+?)×(.+)\)$/
                memory_chip = $1
                memory_module = $2
                memory_total = $3.to_i
                module_size = $4.to_i
                module_count = $5.to_i
                @memories = Groonga["Memories"]
                data = {
                  model: key,
                  chip: memory_chip,
                  module: memory_module,
                  module_total: module_total,
                  module_size: module_size,
                  module_count: module_count
                }
                p key
                p data
                @memories[key] = data
              end
            end
          end

          model = ""
          tab = @driver.find_element(:id => "tab-basic")
          title = tab.find_element(:xpath => "div/div/div[@class='bold']")
          model = title.text if title

          wait.until do
            @driver.find_elements(:class_name => "p-custom")[0].displayed?
          end
          button = @driver.find_elements(:class_name => "p-custom")[0]
          button.click if button.displayed?
          wait.until do
            @driver.find_element(:class_name => "p-total-body").displayed?
          end
          total_body = @driver.find_element(:class_name => "p-total-body")
          p total_body.text
          total_price = extract_price(total_body.text)
          p total_price
          wait.until do
            @driver.find_element(:class_name => "product-config").displayed?
          end
          @driver.find_elements(:class_name => "product-config").each do |product_config|
            h3 = product_config.find_element(:tag_name => "h3")
            if h3.text == "メインメモリ"
              labels = product_config.find_elements(:xpath => "div/dl/dd/ul/li/label")
              if labels
                labels.each do |label|
                  price = label.find_element(:tag_name => "input").attribute("data-price").to_i
                  description = label.find_element(:class => "p-radio-name").text
                  p description
                  p price

                  description =~ /.*(DDR.+) (\d+?GB)×(\d)\(.*計(\d+?)GB\)/
                  memory_chip = $1
                  module_size = $2.to_i
                  module_count = $3.to_i
                  module_total = $4.to_i
                  key = "#{model}_#{module_total}GB"
                  data = {
                    model: model,
                    chip: memory_chip,
                    module_size: module_size,
                    module_count: module_count,
                    module_total: module_total,
                    price: price
                  }
                  p key
                  p data
                  @memories[key] = data
                  spec = {
                    model: model,
                    memory: key,
                    price: total_price + price,
                  }
                  p key
                  p spec
                  @specs[key] = spec
                end
              else
                # no options
                label = product_config.find_elements(:xpath => "div/dl/div/div[@class='p-fixed-name']")
                description = label.text
                description =~ /.*(DDR.+) (\d+?GB)×(\d)\(.*計(\d+?)GB\)/
                memory_chip = $1
                module_size = $2.to_i
                module_count = $3.to_i
                module_total = $4.to_i
                key = "#{model}_#{module_total}GB"
                p key
                data = {
                  model: model,
                  chip: memory_chip,
                  module_size: module_size,
                  module_count: module_count,
                  module_total: module_total,
                  price: 0
                }
                p data
                @memories[key] = data
                spec = {
                  model: model,
                  memory: key,
                  price: total_price,
                }
                @specs[key] = spec
              end
            end
          end
        end
      end

      private

      def extract_price(text)
        text.sub(/円/, '').sub(',', '').to_i
      end

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
