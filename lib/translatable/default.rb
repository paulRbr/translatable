require 'active_record'
require File.expand_path '../active_record.rb', __FILE__

ActiveRecord::Base.extend(Translatable::ActiveRecord::Translate)
ActiveRecord::Base.extend(Translatable::ActiveRecord::Macro)