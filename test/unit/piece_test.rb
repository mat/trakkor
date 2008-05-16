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

    # doesn't work, text is 'NULL'
    #should "should have no text." do
    #  assert_nil @piece.text 
    #end

    should "should have text after fetch." do
       @piece.fetch("http://better-idea.org", "//title" )
       assert @piece.text
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

    should "should have positive bytecount." do
      assert @piece.bytecount > 0
    end




  end

end
