module Translatable
  module ActiveRecord
    module Translate

    # Ask for translations
    def translate

        q = self.scoped
        q.map(&:translate)
        q

      end

    end
  end
end