module Translatable
  module ActiveRecord
    module ClassMethods
      def translation_class
        Translatable.translation_class
      end

      def translated?(name)
        translated_attribute_names.include?(name.to_sym)
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
    end
  end
end