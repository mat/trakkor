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
end
