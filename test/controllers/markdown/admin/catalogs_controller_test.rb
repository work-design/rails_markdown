require 'test_helper'
class Markdown::Admin::CatalogsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @catalog = catalogs(:one)
  end

  test 'index ok' do
    get url_for(controller: 'markdown/admin/catalogs')

    assert_response :success
  end

  test 'new ok' do
    get url_for(controller: 'markdown/admin/catalogs')

    assert_response :success
  end

  test 'create ok' do
    assert_difference('Catalog.count') do
      post(
        url_for(controller: 'markdown/admin/catalogs', action: 'create'),
        params: { catalog: { name: @markdown_admin_catalog.name, path: @markdown_admin_catalog.path } },
        as: :turbo_stream
      )
    end

    assert_response :success
  end

  test 'show ok' do
    get url_for(controller: 'markdown/admin/catalogs', action: 'show', id: @catalog.id)

    assert_response :success
  end

  test 'edit ok' do
    get url_for(controller: 'markdown/admin/catalogs', action: 'edit', id: @catalog.id)

    assert_response :success
  end

  test 'update ok' do
    patch(
      url_for(controller: 'markdown/admin/catalogs', action: 'update', id: @catalog.id),
      params: { catalog: { name: @markdown_admin_catalog.name, path: @markdown_admin_catalog.path } },
      as: :turbo_stream
    )

    assert_response :success
  end

  test 'destroy ok' do
    assert_difference('Catalog.count', -1) do
      delete url_for(controller: 'markdown/admin/catalogs', action: 'destroy', id: @catalog.id), as: :turbo_stream
    end

    assert_response :success
  end

end
