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

    require_relative 'commands/config'
    register IvyBridgeDaddy::Commands::Config, 'config', 'config [SUBCOMMAND]', 'Initialize configuration'
  end
end
