require "application_system_test_case"

class GitsTest < ApplicationSystemTestCase
  setup do
    @markdown_admin_git = markdown_admin_gits(:one)
  end

  test "visiting the index" do
    visit markdown_admin_gits_url
    assert_selector "h1", text: "Gits"
  end

  test "creating a Git" do
    visit markdown_admin_gits_url
    click_on "New Git"

    fill_in "Last commit at", with: @markdown_admin_git.last_commit_at
    fill_in "Last commit message", with: @markdown_admin_git.last_commit_message
    fill_in "Remote url", with: @markdown_admin_git.remote_url
    fill_in "Working directory", with: @markdown_admin_git.working_directory
    click_on "Create Git"

    assert_text "Git was successfully created"
    click_on "Back"
  end

  test "updating a Git" do
    visit markdown_admin_gits_url
    click_on "Edit", match: :first

    fill_in "Last commit at", with: @markdown_admin_git.last_commit_at
    fill_in "Last commit message", with: @markdown_admin_git.last_commit_message
    fill_in "Remote url", with: @markdown_admin_git.remote_url
    fill_in "Working directory", with: @markdown_admin_git.working_directory
    click_on "Update Git"

    assert_text "Git was successfully updated"
    click_on "Back"
  end

  test "destroying a Git" do
    visit markdown_admin_gits_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Git was successfully destroyed"
  end
end
