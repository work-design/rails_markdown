require "application_system_test_case"

class CatalogsTest < ApplicationSystemTestCase
  setup do
    @markdown_admin_catalog = markdown_admin_catalogs(:one)
  end

  test "visiting the index" do
    visit markdown_admin_catalogs_url
    assert_selector "h1", text: "Catalogs"
  end

  test "should create Catalog" do
    visit markdown_admin_catalogs_url
    click_on "New Catalog"

    fill_in "Name", with: @markdown_admin_catalog.name
    fill_in "Path", with: @markdown_admin_catalog.path
    click_on "Create Catalog"

    assert_text "Catalog was successfully created"
    click_on "Back"
  end

  test "should update Catalog" do
    visit markdown_admin_catalogs_url
    click_on "Edit", match: :first

    fill_in "Name", with: @markdown_admin_catalog.name
    fill_in "Path", with: @markdown_admin_catalog.path
    click_on "Update Catalog"

    assert_text "Catalog was successfully updated"
    click_on "Back"
  end

  test "should destroy Catalog" do
    visit markdown_admin_catalogs_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Catalog was successfully destroyed"
  end
end
