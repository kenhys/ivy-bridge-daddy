# frozen_string_literal: true

require 'thor'

module IvyBridgeDaddy
  module Commands
    class Database < Thor

      namespace :database

      desc 'init [PATH]', 'Initialize database'
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def init(path=nil)
        if options[:help]
          invoke :help, ['init']
        else
          require_relative 'database/init'
          IvyBridgeDaddy::Commands::Database::Init.new(path, options).execute
        end
      end
    end
  end
end
