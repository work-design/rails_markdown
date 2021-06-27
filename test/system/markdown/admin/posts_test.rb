require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @markdown_admin_post = markdown_admin_posts(:one)
  end

  test "visiting the index" do
    visit markdown_admin_posts_url
    assert_selector "h1", text: "Posts"
  end

  test "creating a Post" do
    visit markdown_admin_posts_url
    click_on "New Post"

    fill_in "Html", with: @markdown_admin_post.html
    fill_in "Markdown", with: @markdown_admin_post.markdown
    fill_in "Path", with: @markdown_admin_post.path
    fill_in "Title", with: @markdown_admin_post.title
    click_on "Create Post"

    assert_text "Post was successfully created"
    click_on "Back"
  end

  test "updating a Post" do
    visit markdown_admin_posts_url
    click_on "Edit", match: :first

    fill_in "Html", with: @markdown_admin_post.html
    fill_in "Markdown", with: @markdown_admin_post.markdown
    fill_in "Path", with: @markdown_admin_post.path
    fill_in "Title", with: @markdown_admin_post.title
    click_on "Update Post"

    assert_text "Post was successfully updated"
    click_on "Back"
  end

  test "destroying a Post" do
    visit markdown_admin_posts_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Post was successfully destroyed"
  end
end
