require File.dirname(__FILE__) + '/../test_helper'

class TrackerTest < ActiveSupport::TestCase

  ############
  context "A Tracker which recently changed its design" do
      setup do
        @tracker = trackers(:new_design_tracker)
      end

    should "be sick." do
      assert @tracker.sick?
    end

    should "have some pieces." do
      assert_equal 51, @tracker.pieces.length
    end

    should "have some changes." do
      assert_equal 2, @tracker.changes.length
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

    should "fetch the right piece wo error." do
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

    should "fetch an error piece wo text." do
      piece = @tracker.fetch_piece
      assert piece.error
      assert_nil piece.text
    end
  end

end
