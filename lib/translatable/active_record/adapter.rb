module Translatable
  module ActiveRecord
    class Adapter
      # The cache caches attributes that already were looked up for read access.
      # The stash keeps track of new or changed values that need to be saved.
      attr_accessor :record, :stash, :translations
      private :record=, :stash=

      def initialize(record)
        self.record = record
        self.stash = Attributes.new
      end

      def fetch_stash(locale, name)
        value = stash.read(locale, name)
        return value if value
        return nil
      end

      def stash_contains?(locale, name)
        stash.contains?(locale, name)
      end

      def fetch(locale, name, value = nil)
        value = stash_contains?(locale, name) ? fetch_stash(locale, name) : fetch_attribute(locale, name, value)

        return value
      end

      def write(locale, name, value)
        stash.write(locale, name, value)
      end

      def save_translations!
        stash.reject {|locale, attrs| attrs.empty?}.each do |locale, attrs|
          translations = record.translations_by_locale[locale]
          attrs.each { |name, value|
            translation = translations && translations[name] ||
                record.translations.build(:locale => locale.to_s, :scope => record.class.table_name, :key => name)
            translation['record_id'] = record.id
            translation['value'] = value
            translation.save!
          }
        end

        reset
      end

      def reset
        stash.clear
      end

      protected

      def fetch_attribute(locale, name, value = nil)
        if value.nil?
          translation = record.translation_for(locale, name)
          return translation && translation.send(:value)
        else
          translation = record.translation_for_serialized(locale, name, value)
          return translation
        end
      end

    end
  end
end
