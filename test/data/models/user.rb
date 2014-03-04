class User < ActiveRecord::Base
  translatable :name
  validates_presence_of :name, :email
end
