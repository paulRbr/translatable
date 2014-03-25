require File.expand_path('../../test_helper', __FILE__)

class DirtyTrackingTest < Test::Unit::TestCase
  test "dirty tracking works" do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = 'changed title'
    assert_equal ['title'], post.changed

    post.content = 'changed content'
    assert_included 'title', post.changed
    assert_included 'content', post.changed
  end

  test 'dirty tracking works for blank assignment' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = ''
    assert_equal({ 'title' => ['title', ''] }, post.changes)
    post.save
  end

  test 'dirty tracking works for nil assignment' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed

    post.title = nil
    assert_equal({ 'title' => ['title', nil] }, post.changes)
    post.save
  end

  test 'dirty tracking does not track fields that are translatable and we asked to be translated' do
    post = Post.create(:title => 'title', :content => 'content')
    assert_equal [], post.changed
    
    post.title = 'title'
    assert_equal [], post.changed
    
    post.title = 'changed title'
    assert_equal({ 'title' => ['title', 'changed title'] }, post.changes)
    
    post.title = 'title'
    assert_equal [], post.changed

    with_locale(:de) {
      post.translate.title = 'Titel'
      assert_equal [], post.changed
    }
  end

end
