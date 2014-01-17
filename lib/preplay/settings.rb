require "yaml"
require "erb"

module Preplay
  class Settings < Hash

    VERSION = "0.0.1"

    InvalidSettings = Class.new(RuntimeError)

    def self.[](key)
      instance[key]
    end

    def self.[]=(key, val)
      instance[key] = val
    end

    def self.fetch(*args)
      instance.fetch(*args)
    end

    def [](key)
      fetch(key.to_s, nil)
    end

    def []=(key,val)
      store(key.to_s, val)
    end

    DEEP_MERGER = proc { |key, old, new_| Hash === old && Hash === new_ ? old.merge(new_, &DEEP_MERGER) : new_ }

    def initialize(env, *files)
      config = files.inject({}) do |d, file|
        yaml = load_yaml_config(file)[env]
        d.merge(yaml, &DEEP_MERGER)
      end

      self.replace config
    end

    private

    def load_yaml_config(file)
      YAML.load(ERB.new(File.read(file)).result).to_hash
    rescue => err
      raise InvalidSettings, "On settings file #{file.inspect}: #{err.message}", err.backtrace
    end

  end
end
