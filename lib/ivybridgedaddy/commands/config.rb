# frozen_string_literal: true

require 'thor'

module Ivybridgedaddy
  module Commands
    class Config < Thor

      namespace :config

      desc 'init PATH', 'Initialize configuration'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def init(path)
        if options[:help]
          invoke :help, ['init']
        else
          require_relative 'config/init'
          Ivybridgedaddy::Commands::Config::Init.new(path, options).execute
        end
      end
    end
  end
end
