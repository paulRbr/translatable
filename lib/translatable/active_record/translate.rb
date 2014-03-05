module Translatable
  module ActiveRecord
    module Translate
      def self.translate
        self.scoped.translate
      end

    end
  end
end