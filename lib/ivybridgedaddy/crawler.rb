# coding: utf-8
module IvyBridgeDaddy
  module Crawler
    class BaseCrawler

      def cpu?(text)
        text.start_with?("Ryzen") or
          text.start_with?("Celeron") or
          text.start_with?("Ryzen") or
          text.start_with?("A6") or
          text.start_with?("Athlon") or
          text.start_with?("Core")
      end

      def memory?(text)
        text.include?("メモリ")
      end

      def storage?(text)
        text.include?("SSD") or
          text.include?("HDD")
      end

      def graphic?(text)
        text.include?("Radeon") or
          text.include?("UHD") or
          text.include?("GeForce")
      end

      def drive?(text)
        text.include?("DVDスーパーマルチ") or
          text.include?("光学ドライブ無し")
      end

      def os?(text)
        text.include?("Windows") or
          text.include?("OSなし")
      end

      def power?(text)
        text.include?("電源")
      end

      def to_memory_chip(text)
        case text
        when "PC4-17000"
          "DDR4-2133"
        when "PC4-19200"
          "DDR4-2400"
        when "PC4-21300"
          "DDR4-2666"
        when "PC4-22400"
          "DDR4-2800"
        when "PC4-23466"
          "DDR4-2933"
        when "PC4-25600"
          "DDR4-3200"
        when "PC4-27200"
          "DDR4-3400"
        when "PC4-28800"
          "DDR4-3600"
        when "PC4-34100"
          "DDR4-4266"
        end
      end

      def to_memory_module(text)
        case text
        when "DDR4-2133"
          "PC4-17000"
        when "DDR4-2400"
          "PC4-19200"
        when "DDR4-2666"
          "PC4-21300"
        when "DDR4-2800"
          "PC4-22400"
        when "DDR4-2933"
          "PC4-23466"
        when "DDR4-3200"
          "PC4-25600"
        when "DDR4-3400"
          "PC4-27200"
        when "DDR4-3600"
          "PC4-28800"
        when "DDR4-4266"
          "PC4-34100"
        end
      end
    end
  end
end

