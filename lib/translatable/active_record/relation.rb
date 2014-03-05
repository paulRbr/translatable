module Translatable
  module ActiveRecord
    module Relation

      # Ugly hack to override ActiveRecord::Relation#exec_queries method
      # After ruby >= 2.0.0 it's possible to simply prepend http://ruby-doc.org/core-2.0/Module.html#method-i-prepend
      def self.included(base)
        base.class_eval do
          alias_method_chain :exec_queries, :translations
        end
      end

      def translate
        @translate_records = true
        self.eager_load(:translations)
      end

      def exec_queries_with_translations
        if @translate_records
          exec_queries_without_translations.map(&:translate)
        else
          exec_queries_without_translations
        end
      end

    end
  end
end

class Railtie < Rails::Railtie

  initializer "easy_translatable.configure_rails_initialization" do
    ActiveSupport.on_load(:active_record) do
      ActiveRecord::Relation.send :include, Translatable::ActiveRecord::Relation
    end
  end

end if defined?(Rails)
