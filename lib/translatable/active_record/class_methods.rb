module Translatable
  module ActiveRecord
    module ClassMethods
      def translation_class
        Translatable.translation_class
      end

      def translated?(name)
        included = translated_attribute_names.detect { |attr| attr.is_a?(Hash) ? attr.keys.include?(name.to_sym) : attr == name.to_sym }
        !included.nil?
      end

      protected

      def translated_attr_accessor(name)
        define_method(:"#{name}=") do |value|
          write_attribute(name, value)
        end
        define_method(name) do |*args|
          self.read_attribute(name, {:locale => args.detect {|a| !a.is_a? Hash }})
        end
        alias_method :"#{name}_before_type_cast", name
      end

      def locale_from(args)
        args.detect {|a| !a.is_a? Hash }
      end

      def translations_accessor(name)
        define_method(:"#{name}_translations") do
          translations.each_with_object(HashWithIndifferentAccess.new) do |translation, result|
            result[translation.locale] = translation.send(name)
          end
        end
        define_method(:"#{name}_translations=") do |value|
          value.each do |(locale, value)|
            write_attribute name, value, :locale => locale
          end
        end
      end

      def on_after_save_callback(attr_names, callback)
        after_save callback, :if => Proc.new { |rec|
          attr_names.any? do |translatable_attr|
            callback && rec.changes.keys.include?(translatable_attr.to_s)
          end
        }
      end

      def on_before_save_callback(attr_names, callback)
        before_save callback, :if => Proc.new { |rec|
          attr_names.any? do |translatable_attr|
            callback && rec.changes.keys.include?(translatable_attr.to_s)
          end
        }
      end

    end
  end
end