require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

  ############
  context "The class Piece" do
    setup do
      # on vacation
    end

    should "should fetch a title." do
       uri = "http://better-idea.org"
       assert_equal "matthias-luedtke.de - Startseite", Piece.fetch_title(uri)
    end
 
  end

  ############
  context "A new Piece instance" do
    setup do
      @piece = Piece.new
    end

    should "should have no text." do
      assert_nil @piece.text
      assert_nil @piece.text_raw
    end

    should "should have text after fetch." do
       @piece.fetch("http://better-idea.org", "//title" )
       assert @piece.text
       assert @piece.text_raw
    end
 
  end

  ############
  context "A Piece of the //title from better-idea.org" do
      setup do
        @piece = Piece.new
        @piece.fetch("http://better-idea.org", "//title" )
      end

    should "should have text." do
      assert_equal "matthias-luedtke.de - Startseite", @piece.text
    end


  end

end
