require File.dirname(__FILE__) + '/../test_helper'

class ScrapeResultsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scrape_results)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_scrape_result
    assert_difference('ScrapeResult.count') do
      post :create, :scrape_result => { }
    end

    assert_redirected_to scrape_result_path(assigns(:scrape_result))
  end

  def test_should_show_scrape_result
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_scrape_result
    put :update, :id => 1, :scrape_result => { }
    assert_redirected_to scrape_result_path(assigns(:scrape_result))
  end

  def test_should_destroy_scrape_result
    assert_difference('ScrapeResult.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to scrape_results_path
  end
end
