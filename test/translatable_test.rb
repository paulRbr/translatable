# encoding: utf-8

require File.expand_path('../test_helper', __FILE__)

class GlobalizeTest < Test::Unit::TestCase
  test "a translated record has many translations" do
    assert_has_many(Post, :translations)
  end

  test "translations are empty for a new record" do
    assert_equal [], Post.new.translations
  end
end
