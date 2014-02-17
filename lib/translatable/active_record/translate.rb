module Translatable
  module ActiveRecord
    module Translate
      def translate(lang, *attr_names)

        model = self.table_name
        if Translatable::Config.list.has_key?(model) and self.column_names.include?('group_id')

          if attr_names.length == 0
            to_translate = Translatable::Config.list[model]
            q = has_select_values? ? self : self.select("#{model}.*")
          else
            to_translate = attr_names
            q = self
          end

          index = 0
          to_translate.each do |attr|

            if is_in_scope? attr
              index += 1
              if Translatable::Config.list[model].include?(attr.to_s)
                q = q.joins("LEFT JOIN snippets sn#{index} ON sn#{index}.record_id = #{model}.id AND sn#{index}.scope = '#{model}' AND sn#{index}.group_id = #{model}.group_id AND sn#{index}.lang = '#{lang}' AND sn#{index}.key = '#{attr}'").
                    select("COALESCE(sn#{index}.value, '') AS #{attr}")
              else
                q = q.select("#{model}.#{attr}")
              end
            end

          end

          q.scoped
        else
          self.scoped
        end

      end

      private

      def has_select_values?
        self.scoped.select_values.length > 0
      end

      def is_in_scope?(attr)

        if has_select_values?
          select_values = self.scoped.select_values.map { |one|
            if one.is_a?(String)
              one.split(',').map(&:lstrip).map(&:rstrip)
            elsif one.is_a?(Symbol)
              one.to_s
            end
          }.flatten
          p "select_values : #{select_values.reject{ |value| !value.is_a?(String) || !value.split('.').last == '*' && !value.split('.').last == attr  }.inspect}"
          is_present = select_values.reject{ |value| !value.is_a?(String) || !value.split('.').last == '*' && !value.split('.').last == attr  }
          if is_present.nil?
            false
          else
            is_present.length > 0
          end
        else
          true
        end

      end

    end
  end
end