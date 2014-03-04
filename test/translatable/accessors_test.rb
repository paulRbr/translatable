# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class AccessorsTest < Test::Unit::TestCase
  test "*_translatons methods are generated" do
    assert User.new.respond_to?(:name_translations)
  end

  test "new user name_translations" do
    user = User.new
    translations = {}
    assert_equal translations, user.name_translations
  end

end
