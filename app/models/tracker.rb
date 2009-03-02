require 'digest/md5'
require 'net/http'
require 'json'

class Tracker < ActiveRecord::Base
  R_URI = /^(http|https):\/\/.*?$/ix


  validates_presence_of :uri, :xpath
  validates_format_of :uri, :with =>  R_URI
  validates_uniqueness_of :md5sum

  before_validation :nilify_web_hook
  validate :web_hook_nil_or_uri

  named_scope :newest, :order => 'created_at DESC', :limit => 5
  named_scope :web_hooked, :conditions => 'web_hook IS NOT NULL'

  # order: oldest piece first, most recent last
  has_many :pieces, :order => 'created_at ASC' 

  def to_param
    "#{md5sum}"
  end

  def nilify_web_hook
    @attributes['web_hook'] = nil if @attributes['web_hook'] && @attributes['web_hook'].empty?
  end

  def before_create 
    generate_md5_key
    set_name
  end

  def generate_md5_key
    @attributes['md5sum'] = Digest::MD5.hexdigest((object_id + rand(255)).to_s)
  end

  def web_hook_nil_or_uri
    if web_hook && !(Tracker.uri?(web_hook))
       errors.add("Web Hook", "must be an HTTP URI")
    end
  end

  def validate_on_create # is only run the first time a new object is save
    @first_piece = fetch_piece
    if @first_piece.error
       errors.add("URI and XPath", "yield no content")
    end
  end

  def set_name
    self.name ||= "Tracker for #{html_title || uri}"
  end

  def before_update
    set_name
  end

  def Tracker.uri?(str)
    str =~ R_URI
  end

  def after_create
    fetch_piece.save!
  end

  def pieces_errorfree
    pieces.find( :all, :conditions => { :error => nil}, :order => 'created_at ASC' )
  end

  def errs
    pieces.errs
  end

  def redundant_pieces
    pieces.find( :all ) - changes - errs
  end

  def changes(whether_from_cache = [])
    changes_impl
#    key = ['changes',self.id]
#    cached_changes = Cache[key]
#
#    if cached_changes
#     cached_changes = YAML::load(cached_changes)
#      whether_from_cache << true
#      cached_changes
#    else
#
#      fresh_changes = changes_impl
#      whether_from_cache << false
#      Cache[key] = YAML::dump(fresh_changes)
#      fresh_changes
#    end
  end

#  def invalidate_changes
#    key = ['changes',self.id]
#    Cache.delete key
#  end
#
#  def before_destroy
#     invalidate_changes
#   end

  def changes_impl
    all_changes = pieces_errorfree
    dupefree_changes = []

    prev_change = nil
    all_changes.each do |c|

      unless c.same_content(prev_change) then
 	dupefree_changes << c
      end
     
      prev_change = c
    end

    # return most recent change first and on top
    dupefree_changes.reverse!
  end

  def last_change
    #return 'now update recognized' if changes.empty?
    changes.first
  end
  alias :current :last_change

  def first
    changes.last
  end

  def last_piece
    pieces.first.created_at
  end

  def bytes_recorded
     sql = "SELECT SUM(bytecount) FROM pieces WHERE tracker_id=#{self.id}"
     ActiveRecord::Base.connection.select_one(sql).to_a.first.last.to_i
  end

  def html_title
    Piece.fetch_title(self.uri)
  end

  def fetch_piece
    p = Piece.new.fetch(uri, xpath)
    p.tracker = self
    p
  end

  def Tracker.replace_id_funtion(xpath)
    xpath.gsub(/^id\((.*?)\)/x,"//[@id=\\1]")
  end

  def notify_change(old_piece, new_piece)
    begin
    t = {:name => self.name, :uri => self.uri, :xpath => self.xpath }
    n = {:timestamp => new_piece.created_at.xmlschema, :text => new_piece.text}
    o = {:timestamp => old_piece.created_at.xmlschema, :text => old_piece.text}
    payload = {:change => {:tracker => t, :new => n, :old => o}}
    rescue Exception => e
      logger.error("Could not create notification Json: #{e}")
    end
  
    begin
    res = Net::HTTP.post_form(URI.parse(self.web_hook),
                              {'payload' => payload.to_json})
    pp res.body
    rescue
      logger.error("Could not notify tracker #{self.id} via #{self.web_hook}")
    end

  end

  def should_notify?(old_piece, new_piece)
    self.web_hook && !new_piece.error && !old_piece.same_content(new_piece)
  end

  def sick?
    ten_newest_pieces = pieces.find( :all, :order => 'created_at DESC', :limit => 10 )
    if ten_newest_pieces.length >= 10 && ten_newest_pieces.all? { |p| p.error }
      ten_newest_pieces
    else
      false
    end
  end

  def Tracker.find_nodes_by_text(doc, str)
    nodes = doc.search("//").select { |ele| ele.inner_text =~ /#{str}/i }

    nodes = nodes.select{ |n| n.class == Hpricot::Elem }

    parents = Set.new

    nodes.each{ |n| Tracker.collect_parents(n, parents) }

    nodes -= parents.to_a
  end

  def Tracker.live_examples
    Tracker.find(APP_CONFIG['example_trackers'])
  end
 
  def Tracker.newest_trackers
    Tracker.find(:all, :order => 'created_at DESC', :limit => 5)
  end

  def Tracker.remove_all_redundant_pieces
    Tracker.find(:all).each do |t|
      t.redundant_pieces.each { |p| p.destroy }
    end

    :ok
  end

  def Tracker.destroy_sick_trackers
    sick_trackers = Tracker.find(:all).select{ |t| t.sick? }
    sick_trackers.each { |t| t.destroy }
  end

  private
  def Tracker.collect_parents(n, parents)
    return if n.class == Hpricot::Doc

    if n.parent
      parents << n.parent
      collect_parents(n.parent, parents)
    end
  end
  
end
