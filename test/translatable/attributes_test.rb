# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class AttributesTest < Test::Unit::TestCase
  test 'defines accessors for the translated attributes' do
    post = Post.new
    assert post.respond_to?(:title)
    assert post.respond_to?(:title=)
  end

  test "attribute_names returns translated and regular attribute names" do
    assert_equal %w(blog_id content title), Post.new.attribute_names.sort & %w(blog_id content title)
  end

  test "attributes returns translated and regular attributes" do
    post = Post.create(:title => 'foo')
    attributes = post.attributes.slice('id', 'blog_id', 'title', 'content')
    assert_equal({ 'id' => post.id, 'blog_id' => nil, 'title' => 'foo', 'content' => nil }, attributes)
  end

  test "write_attribute for non-translated attributes should return the value" do
    user = User.create(:name => 'Max Mustermann', :email => 'max@mustermann.de')
    new_email = 'm.muster@mann.de'
    assert_equal new_email, user.write_attribute('email', new_email)
  end

  test 'translated_attribute_names returns translated attribute names' do
    assert_equal [:title, :content], Post.translated_attribute_names & [:title, :content]
  end

  test "a translated attribute writer returns its argument" do
    assert_equal 'foo', Post.new.title = 'foo'
  end

  test "a translated attribute reader returns the correct translation for a saved record after locale switching" do
    post = Post.create(:title => 'title')
    post.translate.update_attributes(:title => 'Titel', :locale => :de)
    post.reload


    assert_translated post, :en, :title, 'title'
    assert_translated post.translate, :de, :title, 'Titel'
  end

  test "a translatable attribute reader does not create empty translations when loaded in a new locale" do
    post = Post.create(:title => 'title')
    assert_equal 0, post.translations.length
    I18n.locale = :de

    post.reload
    assert_equal 0, post.translations.length

    post.save
    assert_equal 0, post.translations.length
  end

  test "a translated attribute reader returns the correct translation for an unsaved record after locale switching" do
    post = Post.create(:title => 'title')
    with_locale(:de) { post.translate.title = 'Titel' }

    assert_translated post, :en, :title, 'title'
    assert_translated post, :de, :title, 'Titel'

    post.save
    assert_equal 1, Translation.count
  end

  test "a translated attribute reader returns the correct translation for both saved/unsaved records while switching locales" do
    post = Post.new(:title => 'title')

    post.translate

    with_locale(:de) { post.title = 'Titel' }
    with_locale(:he) { post.title = 'שם' }

    assert_translated post, :de, :title, 'Titel'
    assert_translated post, :he, :title, 'שם'
    assert_translated post, :en, :title, 'title'
    assert_translated post, :he, :title, 'שם'
    assert_translated post, :de, :title, 'Titel'

    post.save
    post.reload

    post.translate

    assert_translated post, :de, :title, 'Titel'
    assert_translated post, :he, :title, 'שם'
    assert_translated post, :en, :title, 'title'
    assert_translated post, :he, :title, 'שם'
    assert_translated post, :de, :title, 'Titel'
  end

  test "a translated attribute reader returns nil if no translations are found on an unsaved record" do
    post = Post.new(:title => 'foo')
    assert_equal 'foo', post.title
    assert_nil post.content
  end

  test "a translated attribute reader returns nil if no translations are found on a saved record" do
    post = Post.create(:title => 'foo')
    post.reload
    assert_equal 'foo', post.title
    assert_nil post.content
  end

  test "before_type_cast reader works for translated attributes" do
    post = Post.create(:title => 'title')
    post.translate
    with_locale(:de) { post.title = 'Titel' }

    with_locale(:en) { assert_equal 'title', post.title_before_type_cast }
    with_locale(:de) { assert_equal 'Titel', post.title_before_type_cast }
  end

  test 'attribute reader without arguments will use the current locale on Translatable or I18n' do
    with_locale(:de) do
      Post.create!(:title => 'Titel', :content => 'Inhalt')
    end
    I18n.locale = :de
    assert_equal 'Titel', Post.first.title

    I18n.locale = :en
    Translatable.locale = :de
    assert_equal 'Titel', Post.first.title
  end

  test 'attribute reader when passed a locale will use the given locale' do
    post = with_locale(:de) do
      Post.create!(:title => 'Titel', :content => 'Inhalt')
    end
    assert_equal 'Titel', post.title(:de)
  end

  test 'serializable attribute with default marshalling, without data' do
    data = nil
    model = SerializedAttr.create
    assert_equal data, model.meta
  end

  test 'serializable attribute with default marshalling, with data' do
    data = {:foo => "bar", :whats => "up"}
    model = SerializedAttr.create(:meta => data)
    assert_equal data, model.meta
  end

  test 'does not update original columns with content not in the default locale' do
    task = Task.create :name => 'Title'

    task.update_attributes :name => 'Titel', :locale => :de

    legacy_task = LegacyTask.find(task.id)
    assert_equal 'Title', legacy_task.name
  end

  test 'updates original columns with content in the default locale' do
    task = Task.create

    with_locale(:de) {
      task.translate.name = 'Neues Titel'
      task.save
    }

    task.update_attributes :name => 'New Title'

    legacy_task = LegacyTask.find(task.id)
    assert_equal 'New Title', legacy_task.name

    with_locale(:de) {
      assert_equal 'Neues Titel', task.translate.name
    }

    with_locale(:de) {
      task.translate.name = 'Der neueste Titel'
      task.save
    }

    with_locale(:de) {
      assert_equal 'Der neueste Titel', task.translate.name
    }

    assert_equal 'New Title', legacy_task.reload.name

    assert_equal 'New Title', task.name
  end

  test 'does not update original columns with content in a different locale' do
    word = Word.create :locale => 'nl', :term => 'ontvrienden', :definition => 'Iemand als vriend verwijderen op een sociaal netwerk'
    legacy_word = LegacyWord.find(word.id)
    assert_equal nil, legacy_word.term

    word.update_attributes :term => 'unfriend', :definition => 'To remove someone as a friend on a social network'

    assert_equal 'unfriend',    word.term
    Translatable.locale = :nl
    assert_equal 'ontvrienden', word.translate.term
    assert_equal 'unfriend', legacy_word.reload.term

    with_locale(:de) {
      word.translate.update_attributes :term => 'entfreunde', :definition => 'Um jemanden als Freund in einem sozialen Netzwerk zu entfernen', :locale => :de
    }

    with_locale(:de) {
      assert_equal 'entfreunde',  word.translate.term
    }
    assert_equal 'unfriend',    word.reload.term
    with_locale(:nl) {
      assert_equal 'ontvrienden', word.translate.term
    }
    assert_equal 'unfriend', legacy_word.reload.term
  end

  test 'updates original columns with content in the same locale' do
    I18n.locale = :nl
    word = Word.create :term => 'ontvrienden', :definition => 'Iemand als vriend verwijderen op een sociaal netwerk'

    with_locale(:en) {
      word.translate.update_attributes :term => 'unfriend', :definition => 'To remove someone as a friend on a social network'
      assert_equal 2, Translation.count
    }

    word.update_attributes :term => 'ontvriend'
    assert_equal 2, Translation.count

    legacy_word = LegacyWord.find(word.id)
    assert_equal 'ontvriend', word.term
    with_locale(:en) {
      assert_equal 'unfriend',  word.translate.term
    }
    assert_equal 'ontvriend', legacy_word.term
  end

end
