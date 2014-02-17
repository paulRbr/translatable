module Translatable
  class Config
    include Singleton
    attr_accessor :list

    def self.file=  path
      instance.list = YAML.load_file path
    end

    def self.list
      instance.list
    end
  end
end