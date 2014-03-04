class Word < ActiveRecord::Base
  translatable :term, :definition
end
