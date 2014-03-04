class SerializedAttr < ActiveRecord::Base
  serialize :meta
  translatable :meta
end
