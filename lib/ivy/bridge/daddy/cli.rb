# frozen_string_literal: true

require 'thor'

module Ivy
  module Bridge
    module Daddy
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
          puts "v#{Ivy::Bridge::Daddy::VERSION}"
        end
        map %w(--version -v) => :version
      end
    end
  end
end
