require 'test_helper'
class Markdown::PostsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @markdown_post = create markdown_posts
  end

  test 'index ok' do
    get markdown_posts_url
    assert_response :success
  end

  test 'new ok' do
    get new_markdown_post_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Post.count') do
      post markdown_posts_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get markdown_post_url(@markdown_post)
    assert_response :success
  end

  test 'edit ok' do
    get edit_markdown_post_url(@markdown_post)
    assert_response :success
  end

  test 'update ok' do
    patch markdown_post_url(@markdown_post), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Post.count', -1) do
      delete markdown_post_url(@markdown_post)
    end

    assert_response :success
  end

end
