require File.dirname(__FILE__) + '/../test_helper'

class TrackerTest < ActiveSupport::TestCase

  should_require_attributes :uri, :xpath
  should_require_unique_attributes :md5sum

  should_have_many :pieces

  #should_have_indices :md5sum
  should_allow_values_for :uri, "http://example.com"

  should_not_allow_values_for :uri, "bad 1"
  should_not_allow_values_for :uri, "bad 1"

  ############
  context "A Tracker which recently changed its design" do
      setup do
        @tracker = trackers(:new_design_tracker)
      end

    should "be sick." do
      assert @tracker.sick?
    end

    should "have some pieces" do
      assert_equal 52, @tracker.pieces.length
    end

    should "have some changes" do
      assert_equal 3, @tracker.changes.length
    end

    should "have some errors" do
      assert_equal 20, @tracker.error_pieces.length
    end

    should "return the right change texts" do
      # Tracker.changes return changes in reverse!
      assert_equal '3rd change', @tracker.changes[0].text
      assert_equal '2nd change', @tracker.changes[1].text
      assert_equal '1st change', @tracker.changes[2].text
    end

   # error_pieces UMBENNEN nach errors
   # und dann named_scoped fuer errors benutzen

    should "return unnecessary pieces, but no errors or changes" do
      changes = @tracker.changes
      errors  = @tracker.error_pieces

      #assert_equal '2nd change', @tracker.unnecessary_pieces
    end

  end

  ############
  context "A nice Tracker without flaws" do
      setup do
        @tracker = trackers(:nice_tracker)
      end

    should "not be sick" do
      assert !@tracker.sick?
    end

    should "have some pieces" do
      assert_equal 3, @tracker.pieces.length
    end

    should "have some changes" do
      assert_equal 3, @tracker.changes.length
    end

    should "have no error pieces" do
      assert @tracker.error_pieces.empty?
    end

    should "have only errorfree pieces" do
      assert @tracker.pieces_errorfree == @tracker.pieces
    end

  end
  ############
  context "A fresh Tracker" do
      setup do
        @tracker = Tracker.new
        @tracker.uri = "http://better-idea.org"
        @tracker.xpath = "//title"
      end

    should "have no pieces." do
      assert @tracker.pieces.empty?
    end

    should "have no changes." do
      assert @tracker.changes.empty?
    end

    should "not be sick." do
      assert !@tracker.sick?
    end
  end

  ############
  context "A Tracker for the //title from better-idea.org" do
      setup do
        @tracker = Tracker.new
        @tracker.uri = "http://better-idea.org"
        @tracker.xpath = "//title"
      end

    should "fetch the right piece wo error" do
      piece = @tracker.fetch_piece
      assert_equal "Matthias Lüdtke", piece.text
      assert_nil piece.error
    end
  end

  context "A Tracker for a non-existent DOM element" do
      setup do
        @tracker = Tracker.new
        @tracker.uri = "http://www.wowwiki.com/Portal:Main" 
        @tracker.xpath = "//foo"
      end

    should "fetch an error piece wo text" do
      piece = @tracker.fetch_piece
      assert piece.error
      assert_nil piece.text
    end
  end

  ############
#  context "A Tracker that caches its changes" do
#      setup do
#        @tracker = trackers(:nice_tracker)
#        @tracker.invalidate_changes
#      end
#
#    should "deliver fresh pieces from db on the first invocation" do
#      is_cached_result = [] # hack to get info out of changes()
#      changes = @tracker.changes(is_cached_result)
#      assert_equal 3, changes.length
#      assert is_cached_result.include?(false)
#    end

 #   should "deliver cached pieces on the second invocation" do
#      changes = @tracker.changes
#      is_cached_result = [] # hack to get info out of changes()
#      changes = @tracker.changes(is_cached_result)

 #     assert_equal 3, changes.length
 #     assert is_cached_result.include?(true)
 #   end

  #  should "deliver the same changes, whether fresh or cached" do
  #    fresh_changes = @tracker.changes
  #    cached_changes = @tracker.changes

  #    assert_equal fresh_changes, cached_changes
  #  end
  #end

end
