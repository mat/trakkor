require File.dirname(__FILE__) + '/../test_helper'

class PieceTest < ActiveSupport::TestCase

  should_belong_to :tracker

  ############
  context "The class Piece" do
    setup do
      # on vacation
      i18n_file = File.dirname(__FILE__) + '/../files/i18n.html'
      @i18n_data = IO.read(i18n_file)
    end

    should "fetch a title." do
       uri = "http://better-idea.org"
       assert_equal "Matthias Lüdtke", Piece.fetch_title(uri)
    end
 
    should "extract an i18n string correctly." do
       xpath = "//body[@id='intertwingly-net']/div[2]/div/blockquote[1]/p/code"
       _, plain_text = Piece.extract_text(@i18n_data,xpath)
       assert_equal 'Iñtërnâtiônàlizætiøn', plain_text
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

    should "have text after fetch." do
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

    should "have text." do
      assert_equal "Matthias Lüdtke", @piece.text
    end

    should "have positive bytecount." do
      assert @piece.bytecount > 0
    end




  end

end
