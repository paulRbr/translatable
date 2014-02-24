module Translatable
  module ActiveRecord
    module Macro

      def translatable(*attr_names)

        options = attr_names.extract_options!
        setup_translatable!(options) unless translatable?

        attr_names = attr_names.map(&:to_sym)
        attr_names -= translated_attribute_names if defined?(translated_attribute_names)

        if attr_names.present?
          translation_class.instance_eval %{
            attr_accessible :#{attr_names.join(', :')}
                                          }

          attr_names.each do |attr_name|
            # Detect and apply serialization.
            serializer = self.serialized_attributes[attr_name.to_s]
            if serializer.present?
              if defined?(::ActiveRecord::Coders::YAMLColumn) &&
                  serializer.is_a?(::ActiveRecord::Coders::YAMLColumn)

                serializer = serializer.object_class
              end

              translation_class.send :serialize, attr_name, serializer
            end

            # Create accessors for the attribute.
            translated_attr_accessor(attr_name)
            translations_accessor(attr_name)

            # Add attribute to the list.
            self.translated_attribute_names << attr_name
          end

          Translatable.add_translatable self

        end
      end

      def class_name
        @class_name ||= begin
          class_name = table_name[table_name_prefix.length..-(table_name_suffix.length + 1)].downcase.camelize
          pluralize_table_names ? class_name.singularize : class_name
        end
      end

      def translatable?
        included_modules.include?(InstanceMethods)
      end

      protected
      def setup_translatable!(options)
        options[:table_name] ||= Translatable.translation_class.table_name
        options[:foreign_key] ||= 'record_id'
        options[:conditions] ||= ''

        class_attribute :translated_attribute_names, :translation_options, :fallbacks_for_empty_translations
        self.translated_attribute_names = []
        self.translation_options        = options
        self.fallbacks_for_empty_translations = options[:fallbacks_for_empty_translations]

        # Alias original relation method so we can safely override it in ClassMethods.
        #class << self
        #  alias relation_without_globalize relation
        #end

        include InstanceMethods
        extend  ClassMethods

        translation_class.table_name = options[:table_name]

        has_many :translations, :class_name  => translation_class.name,
                 :foreign_key => options[:foreign_key],
                 :conditions  => options[:conditions],
                 :dependent   => :destroy,
                 :extend      => HasManyExtensions,
                 :autosave    => false

        #after_create :save_translations!
        #after_update :save_translations!

        translation_class.instance_eval %{ attr_accessible :lang }
      end
    end

    module HasManyExtensions
      def find_or_initialize_by_locale(locale)
        with_locale(locale.to_s).first || build(:locale => locale.to_s)
      end
    end
  end
end
