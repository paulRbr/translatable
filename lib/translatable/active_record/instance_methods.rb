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
        !@translate_me.nil? && @translate_me
      end

      def read_attribute(name, options = {})
        options = {:translated => true, :locale => nil}.merge(options)
        if translated?(name) and options[:translated]
          serialized_value = super(name) if self.serialized_attributes.has_key?(name)
          if translate? && (value = translatable.fetch(options[:locale] || Translatable.locale, name, serialized_value))
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

      # Fetch translations per keys in the form
      # model_attr_serialized_attribute
      # E.G.1: ```Model``` has attribute ```config``` which has a key ```auto_save```
      #         will have a translation key ```config_auto_save```
      # E.G.2: ```Model``` has attribute ```config``` which is an array of ```user_id => ([0-9]+)```
      #         will have translations key containing the index: ```config_user_id_0```, ```config_user_id_1```...
      def translation_for_serialized(locale, name, value, build_if_missing = false)

        unless translation_caches["#{locale}_#{name}"]
          engine = self.serialized_attributes.has_key?(name) ? nil : JSON
          deserialized_value = engine.nil? ? value : engine.load(value)

          only = self.translated_serialized_attributes[name.to_sym].map(&:to_s)
          if only.empty?
            regex_keys = /\A#{name.to_s}_([a-z_]+[a-z])(?:_([0-9]*))?\Z/
          else
            regex_keys = /\A#{name.to_s}_(#{only.join('|')})(?:_([0-9]*))?\Z/
          end
          # Fetch translations from database as those in the translation collection may be incomplete
          _translations = translations.select{|t| t.locale.to_s == locale.to_s && t.key.to_s =~ regex_keys }
          _translations.each do |t|
            matched = t.key.match regex_keys
            unless matched.nil?
              if matched.size == 3
                sub_attr = matched[1]
                index = matched[2].to_i
                value[index][sub_attr] = t.value if value.size > index && value[index].has_key?(sub_attr)
              elsif matched.size == 3
                sub_attr = matched[1]
                value[sub_attr] = t.value if value.has_key?(sub_attr)
              end
            end
          end

          translation_caches["#{locale}_#{name}"] = value
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
