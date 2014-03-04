ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :translations, :force => true do |t|
    t.string   :key
    t.string   :scope
    t.string   :record_id
    t.string   :value
    t.string   :locale
  end

  create_table :tasks, :force => true do |t|
    t.string :name
    t.datetime :created_at
  end

  create_table :words, :force => true do |t|
    t.string :term
    t.text :definition
    t.string :locale
  end

  create_table :serialized_attrs, :force => true do |t|
    t.text :meta
  end

  create_table :blogs, :force => true do |t|
    t.string   :description
  end

  create_table :posts, :force => true do |t|
    t.string     :title
    t.string     :content
    t.references :blog
    t.boolean    :published
  end

  create_table :users, :force => true do |t|
    t.string   :email
    t.datetime :created_at
  end
end
