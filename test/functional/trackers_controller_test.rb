require File.dirname(__FILE__) + '/../test_helper'

class TrackersControllerTest < ActionController::TestCase

  fixtures :trackers
  fixtures :pieces

  GOOD_ID = '68b329da9893e34099c7d8ad5cb9c940'
  NO_PIECES_ID = '16cb80c98c24a346a5d5cbbdb3a86499'

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

  def test_find_xpath_should_display_error_unless_uri_and_search_given
    get :find_xpath, :uri => "" , :q => "" 
    assert_equal "Please provide an URI and a search term." , flash[:error]
    assert_response :success
  end

  def test_find_xpath_should_display_error_unless_uri_is_http_uri
    get :find_xpath, :uri => "foobar" , :q => "baz" 
    assert_equal "Please provide a proper HTTP URI like http://w3c.org" , flash[:error]
    assert_response :success
  end

  def test_find_xpath_should_display_error_unless_uri_points_to_any_document
    get :find_xpath, :uri => "http://better-idea.org/foo" , :q => "baz" 
    assert_equal "Could not fetch the document, server returned: 404 Not Found" , flash[:error]
    assert_response :success
  end

  def test_find_xpath_should_display_error_if_uri_points_to_non_html_document
    get :find_xpath, :uri => "http://better-idea.org/img/jichtplaner_plan.gif" , :q => "foo" 
    assert_nil assigns(:piece)
    assert_equal "URI does not point to a text document but a image/gif file." , flash[:error]
    assert_response :success
  end

  def test_show_on_missing_tracker
    get :show, :id => 'does-not-exist'
    assert_response 404
  end

  def test_simple_show
    get :show, :id => GOOD_ID
    assert_response :success # HTTP 200
    assert_not_nil assigns(:tracker)
    assert_not_nil assigns(:changes)

    assert @response['Last-Modified']

    last_modified = Tracker.find_by_md5sum(GOOD_ID).last_modified
    assert_equal last_modified.httpdate, @response['Last-Modified']
  end

  def test_cached_show_with_fresh_if_modified_since
    return #FIXME Make cache test work
    last_modified = Tracker.find_by_md5sum(GOOD_ID).last_modified

    get(:show, {:id => GOOD_ID, 'HTTP_IF_MODIFIED_SINCE' => last_modified.httpdate})
    assert_response 304
    assert @response['Last-Modified']
    assert_equal last_modified.httpdate, @response['Last-Modified']
  end

  def test_show_with_microsummary
    get :show, :id => GOOD_ID, :format => "microsummary"
    assert_response :success # HTTP 200
    end

  def test_show_with_microsummary_on_tracker_with_no_pieces
    get :show, :id => NO_PIECES_ID, :format => "microsummary"
    assert_response :success # HTTP 200
  end

  context "on GET to :show" do
    setup { get :show, :id => GOOD_ID, :format => "microsummary" }

    should_assign_to :tracker
    should_respond_with :success
    should_not_set_the_flash
  end

  def test_show_on_tracker_with_no_pieces
    get :show, :id => NO_PIECES_ID
    assert_response :success # HTTP 200
    assert_not_nil assigns(:tracker)
    assert_not_nil assigns(:changes)

    assert @response['Last-Modified']
  end

  def test_show_atom_on_tracker_with_no_pieces
    get :show, :id => NO_PIECES_ID, :format => "atom"
    assert_response :success # HTTP 200
    assert_not_nil assigns(:tracker)
    assert_not_nil assigns(:changes)

    assert @response['Last-Modified']
  end

  def test_show_with_errors_on_tracker_with_no_errors
    get :show, :id => GOOD_ID, :errors => "show"
    assert_response :success # HTTP 200
    assert_not_nil assigns(:tracker)
    assert_not_nil assigns(:changes)

    assert @response['Last-Modified']
  end

  def test_create_amazon
    params = {:tracker => { :uri => "http://www.amazon.de/Driven-Development-Example-Addison-Wesley-Signature/dp/0321146530",
                  :xpath => "//div[@id=''priceBlock'']/table/tr[1]/td[2]/b[1]" } }
    get :new, params
    assert_response :success # HTTP 200"
  end

  def test_destroy
    get :show, :id => GOOD_ID
    assert_response 200

    delete :destroy, :id => GOOD_ID
    assert_response 302 # redirect to confirmation page

    get :show, :id => GOOD_ID
    assert_response 404
  end
end
