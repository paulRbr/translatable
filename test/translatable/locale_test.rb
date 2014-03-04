# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class LocaleTest < Test::Unit::TestCase
  test "Translatable has locale accessors" do
    assert Translatable.respond_to?(:locale)
    assert Translatable.respond_to?(:locale=)
  end

  test "Translatable.locale reader can be called before a locale was set" do
    Translatable.locale = nil
    assert_nothing_raised { Translatable.locale }
  end

  test 'Translatable locale setting' do
    assert_equal :en, I18n.locale
    assert_equal :en, Translatable.locale

    I18n.locale = :de
    assert_equal :de, I18n.locale
    assert_equal :de, Translatable.locale
  end

  test "Translatable locale setting with strings" do
    I18n.locale = 'de'
    Translatable.locale = 'de'
    assert_equal I18n.locale, Translatable.locale

    I18n.locale = 'de'
    Translatable.locale = :de
    assert_equal I18n.locale, Translatable.locale

    I18n.locale =  :de
    Translatable.locale = 'de'
    assert_equal I18n.locale, Translatable.locale
  end

  test 'with_locale temporarily sets the given locale and yields the block' do
    Translatable.locale = :en
    assert_equal :en, Translatable.locale
    Translatable.with_locale :de do |locale|
      assert_equal :de, Translatable.locale
      assert_equal :de, locale
    end
    assert_equal :en, Translatable.locale
  end

  test 'with_locale resets the locale to the previous one even if an exception occurs in the block' do
    assert_equal :en, Translatable.locale
    begin
      Translatable.with_locale :de do |locale|
        raise
      end
    rescue Exception
    end
    assert_equal :en, Translatable.locale
  end

  test "attribute saving goes by content locale and not global locale" do
    Translatable.locale = :de
    assert_equal :en, I18n.locale
    post = Post.create :title => 'foo'
    post.translate.title = 'bar'
    post.save
    assert_equal :de, Post.first.translations.first.locale.to_sym
  end

  test "attribute loading goes by content locale and not global locale" do
    post = Post.create(:title => 'title')
    assert_translated Post.first, :en, :title, 'title'

    Translation.create(:key => 'title', :scope => 'post', :locale => 'de', :value => 'titel', :record_id => post.id)

    assert_translated Post.first, :en, :title, 'title'
    assert_translated Post.first.translate, :de, :title, 'titel'
  end
end
