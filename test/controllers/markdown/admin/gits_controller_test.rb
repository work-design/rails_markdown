require 'test_helper'
class Markdown::Admin::GitsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @markdown_admin_git = create markdown_admin_gits
  end

  test 'index ok' do
    get admin_gits_url
    assert_response :success
  end

  test 'new ok' do
    get new_admin_git_url
    assert_response :success
  end

  test 'create ok' do
    assert_difference('Git.count') do
      post admin_gits_url, params: { #{singular_table_name}: { #{attributes_string} } }
    end

    assert_response :success
  end

  test 'show ok' do
    get admin_git_url(@markdown_admin_git)
    assert_response :success
  end

  test 'edit ok' do
    get edit_admin_git_url(@markdown_admin_git)
    assert_response :success
  end

  test 'update ok' do
    patch admin_git_url(@markdown_admin_git), params: { #{singular_table_name}: { #{attributes_string} } }
    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Git.count', -1) do
      delete admin_git_url(@markdown_admin_git)
    end

    assert_response :success
  end

end
