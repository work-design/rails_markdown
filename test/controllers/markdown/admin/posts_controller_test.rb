require 'test_helper'
class Markdown::Admin::PostsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @markdown_admin_post = create markdown_admin_posts
  end

  test 'index ok' do
    get admin_posts_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_post_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Post.count') do
      post admin_posts_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_post_url(@markdown_admin_post)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_post_url(@markdown_admin_post)
    assert_response :success
  end

  test 'update ok' do
    patch admin_post_url(@markdown_admin_post), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Post.count', -1) do
      delete admin_post_url(@markdown_admin_post)
    end

    assert_response :success
  end

end
