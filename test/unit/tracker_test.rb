require File.dirname(__FILE__) + '/../test_helper'

class TrackerTest < ActiveSupport::TestCase

  def setup
    @new_design = trackers(:new_design_tracker)
  end

  def test_fresh_tracker_has_no_pieces
    assert_equal 0, Tracker.new.pieces.length
  end

  def test_fresh_tracker_has_no_changes
    assert_equal 0, Tracker.new.changes.length
  end

  def test_fresh_tracker_is_not_sick
    assert !(Tracker.new.sick?)
  end

  def test_sickness_of_tracker_with_new_design
    assert @new_design.sick?
  end
  
  def test_count_changes_of_tracker_with_new_design
    assert_equal 2, @new_design.changes.length
  end

  def test_count_pieces_of_tracker_with_new_design
    assert_equal 51, @new_design.pieces.length
  end

  ############
  context "A Tracker for the //title from better-idea.org" do
      setup do
        @tracker = Tracker.new
        @tracker.uri = "http://better-idea.org"
        @tracker.xpath = "//title"
      end

    should "should fetch the right piece wo error." do
      piece = @tracker.fetch_piece
      assert_equal "matthias-luedtke.de - Startseite", piece.text
      assert_nil piece.error
    end
  end

  context "A Tracker for a non-existent DOM element" do
      setup do
        @tracker = Tracker.new
        @tracker.uri = "http://www.wowwiki.com/Portal:Main" 
        @tracker.xpath = "//foo"
      end

    should "should fetch an error piece wo text." do
      piece = @tracker.fetch_piece
      assert piece.error
      assert_nil piece.text
    end
  end

end
