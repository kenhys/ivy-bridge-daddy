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
        text.include?("DVDスーパーマルチ")
      end

      def os?(text)
        text.include?("Windows") or
          text.include?("OSなし")
      end

      def power?(text)
        text.include?("ATX電源") or
          text.include?("TFX電源")
      end
    end
  end
end

