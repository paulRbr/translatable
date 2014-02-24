module Translatable
  module ActiveRecord
    module InstanceMethods
      delegate :translated_locales, :to => :translations

      def translatable
        @translatable ||= Adapter.new(self)
      end

      def self.included(base)
        # only Rails > 3.1.x compatibility
        base.class_eval %{
          def attributes=(attributes, *args)
            with_given_locale(attributes) { super }
          end
        }
      end


      #def write_attribute(name, value, options = {})
      #  if translated?(name)
      #    options = {:locale => Translatable.locale}.merge(options)
      #
      #    # Dirty tracking, paraphrased from
      #    # ActiveRecord::AttributeMethods::Dirty#write_attribute.
      #    name_str = name.to_s
      #    if attribute_changed?(name_str)
      #      # If there's already a change, delete it if this undoes the change.
      #      old = changed_attributes[name_str]
      #      changed_attributes.delete(name_str) if value == old
      #    else
      #      # If there's not a change yet, record it.
      #      old = globalize.fetch(options[:locale], name)
      #      old = old.clone if old.duplicable?
      #      changed_attributes[name_str] = old if value != old
      #    end
      #
      #    translatable.write(options[:locale], name, value)
      #  else
      #    super(name, value)
      #  end
      #end

      def translate
        @translate_me = true
        self
      end

      def translate?
        !@translate_me.nil? && @translate_me = true
      end

      def read_attribute(name, options = {})
        options = {:translated => true, :locale => nil}.merge(options)
        if translated?(name) and options[:translated]
          if translate? && (value = translatable.fetch(options[:locale] || Translatable.locale, name))
            value
          else
            super(name)
          end
        else
          super(name)
        end
      end

      def translated?(name)
        self.class.translated?(name)
      end

      def translation_for(locale, name, build_if_missing = false)
        unless translation_caches["#{locale}_#{name}"]
          # Fetch translations from database as those in the translation collection may be incomplete
          _translation = translations.detect{|t| t.locale.to_s == locale.to_s && t.key.to_s == name.to_s }
          _translation ||= translations.build(:locale => locale) if build_if_missing
          translation_caches["#{locale}_#{name}"] = _translation if _translation
        end
        translation_caches["#{locale}_#{name}"]
      end

      def translation_caches
        @translation_caches ||= {}
      end


      def with_given_locale(attributes, &block)
        attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)

        locale = respond_to?(:locale=) ? attributes.try(:[], :locale) :
            attributes.try(:delete, :locale)

        if locale
          Translatable.with_locale(locale, &block)
        else
          yield
        end
      end
    end
  end
end
