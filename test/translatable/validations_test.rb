require File.expand_path('../../test_helper', __FILE__)

class ValidationsTest < Test::Unit::TestCase
  def teardown
    super
  end

  # TODO
  #
  # test "a record with valid values on non-default locale validates" do
  #   assert Post.create(:title => 'foo', :locale => :de).valid?
  # end

  test "update_attributes succeeds with valid values" do
    post = Post.create(:title => 'foo')
    post.update_attributes(:title => 'baz')
    assert post.valid?
    assert_equal 'baz', Post.first.title
  end

  test "update_attributes fails with invalid values" do
    post = Post.create(:title => 'foo')
    assert !post.update_attributes(:title => '')
    assert !post.valid?
    assert_not_nil post.reload.attributes['title']
    assert_equal 'foo', post.title
  end


  # test "validates_associated" do
  # end
end
