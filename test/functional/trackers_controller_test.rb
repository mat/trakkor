require File.dirname(__FILE__) + '/../test_helper'

class TrackersControllerTest < ActionController::TestCase
#  def test_should_get_index
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:trackers)
#  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_get_new_w_preview
    get :new, :tracker => { :uri => "http://example.com" , :xpath => "//title" }
    assert_not_nil assigns(:piece)
    assert_response :success
  end

  def test_should_get_new_wo_preview_when_uri_and_xpath_are_missing
    get :new
    assert_nil assigns(:piece)
    assert_response :success
  end

#  def test_should_create_tracker
#    assert_difference('tracker.count') do
#      post :create, :tracker => { }
#    end

#    assert_redirected_to tracker_path(assigns(:tracker))
#  end

#  def test_should_show_tracker
#    get :show, :id => 1
#    assert_response :success
#  end

#  def test_should_get_edit
#    get :edit, :id => 1
#    assert_response :success
#  end

 # def test_should_update_tracker
 #   put :update, :id => 1, :tracker => { }
 #   assert_redirected_to tracker_path(assigns(:tracker))
 # end

#  def test_should_destroy_tracker
#    assert_difference('Tracker.count', -1) do
#      delete :destroy, :id => 1
#    end
#
#    assert_redirected_to trackers_path
#  end
end
