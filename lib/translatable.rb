require File.join(File.dirname(__FILE__), 'translatable/default.rb')

module Translatable

  @@translatable ||= Hash.new
  @@translation_class ||= nil

  class << self
    def locale
      I18n.locale
    end

    def locale=(locale)
      set_locale(locale)
    end

    def with_locale(locale, &block)
      previous_locale = read_locale
      set_locale(locale)
      result = yield(locale)
      set_locale(previous_locale)
      result
    end

    def translation_class_name=(klass)
      @@translation_class = klass.constantize
    end
    def translation_class
      @@translation_class ||= nil
    end

    # Hash of models that are translatable (values are the attrs)
    def list
      @@translatable ||= Hash.new
    end

    def add_translatable(klass)
      if @@translatable.has_key? klass.name
        klass.translated_attribute_names.each do |attr|
          @@translatable[klass.name] << attr unless @@translatable[klass.name].include?(attr)
        end
      else
        @@translatable[klass.name] = klass.translated_attribute_names
      end
    end

    protected

    def read_locale
      Thread.current[:translatable_locale]
    end

    def set_locale(locale)
      Thread.current[:translatable_locale] = locale.try(:to_sym)
    end
  end

end