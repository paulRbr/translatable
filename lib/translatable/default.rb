require File.expand_path '../config.rb', __FILE__
require File.expand_path '../active_record.rb', __FILE__

module Translatable
  class Base

    include Singleton
    attr_accessor :models, :clicrdv_models

    CLICRDV_TYPES = %w(model customfield preprosition)

    def self.is_a_customfield?(str)
      str.match(/\Acustomfields/)
    end

    def self.is_a_preposition?(str)
      str.match(/\Apreposition/)
    end

    def self.is_an_ar_model?(str)
      is_it = false
      begin
        model = str.singularize.camelize.constantize
        is_it = true unless model.superclass.name == 'ActiveRecord::base'
      rescue NameError
      end
      is_it
    end

    def self.type str
      if is_model str
        'model'
      elsif is_customfield str
        'customfield'
      end
    end

    # Get all translatables models
    # @param array of things to translate
    # @return an array of three elements : ARModels, Customfields and Preprositions
    def self.clicrdv_models(hash=nil)
      if hash.nil? || hash.empty?
        process_me = Config.list
      else
        process_me = hash
      end
      # Don't remove the v in the block parameters |k,v| this because of Ruby 1.8.7
      ar_models = process_me.reject{ |k,v| !is_an_ar_model?(k) }
      customfields = process_me.reject{ |k,v| !is_a_customfield?(k) }
      prepositions = process_me.reject{ |k,v| !is_a_preposition?(k) }

      [ar_models, customfields, prepositions]
    end
  end
end

ActiveRecord::Base.extend(Translatable::ActiveRecord::Translate)