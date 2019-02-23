# frozen_string_literal: true

require 'thor'

module IvyBridgeDaddy
  # Handle the application command line parsing
  # and the dispatch to various command objects
  #
  # @api public
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc 'version', 'ivy-bridge-daddy version'
    def version
      require_relative 'version'
      puts "v#{IvyBridgeDaddy::VERSION}"
    end
    map %w(--version -v) => :version

    desc 'crawl SITE, [TASK]', 'Command description...'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def crawl(site, task=nil)
      if options[:help]
        invoke :help, ['crawl']
      else
        require_relative 'commands/crawl'
        IvyBridgeDaddy::Commands::Crawl.new(site, task, options).execute
      end
    end

    require_relative 'commands/database'
    register IvyBridgeDaddy::Commands::Database, 'database', 'database [SUBCOMMAND]', 'Initialize database'

    require_relative 'commands/config'
    register IvyBridgeDaddy::Commands::Config, 'config', 'config [SUBCOMMAND]', 'Initialize configuration'
  end
end
