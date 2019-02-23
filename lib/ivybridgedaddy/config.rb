require "yaml"

module IvyBridgeDaddy

   IVYBRIDGEDADDY_CONFIG_FILE = "ivy-bridge-daddy.yml"
   IVYBRIDGEDADDY_DOT_CONFIG = ".ivy-bridge-daddy"
   IVYBRIDGEDADDY_DB_FILE = "db/ivy-bridge-daddy.db"

  class Config

    attr_reader :database_path

    def initialize
      @keys = {}
    end

    def home
      dir = ENV["IVYBRIDGEDADDY_HOME"] || File.join(ENV["HOME"], IVYBRIDGEDADDY_DOT_CONFIG)
      Dir.mkdir(dir) unless Dir.exist?(dir)
      dir
    end

    def path
      File.join(home, IVYBRIDGEDADDY_CONFIG_FILE)
    end

    def load
      setup unless File.exist?(path)
      YAML.load_file(path).each do |key, value|
        @keys[key] = value
        instance_variable_set("@#{key}", value)
      end
    end

    def database_path
      dir = File.join(home, "db")
      Dir.mkdir(dir) unless Dir.exist?(dir)
      File.join(home, IVYBRIDGEDADDY_DB_FILE)
    end

    def setup
      open(path, "w+") do |file|
        @keys["database_path"] = database_path
        file.puts(YAML.dump(@keys))
      end
    end

    def save
      config = {}
      instance_variables.each do |var|
        key = var.to_s.sub(/^@/, '')
        unless key == "keys"
          config[key] = instance_variable_get(var.to_s)
        end
      end
      File.open(path, "w+") do |file|
        file.puts(YAML.dump(config))
      end
    end

  end
end
