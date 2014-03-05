# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class TranslationForTest < Test::Unit::TestCase
  test "translation_for returns the translation for the locale passed in as an argument" do
    post = Post.create(:title => 'title', :content => 'content')

    with_locale(:de) {
      post.translate.update_attributes(:title => 'Titel', :content => 'Inhalt')
    }

    assert_equal 'Titel', post.translation_for(:de, 'title').value
    assert_equal 'Inhalt', post.translation_for(:de, 'content').value
  end
end


