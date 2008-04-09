  atom_feed(:root_url => url_for(@tracker)) do |feed|
    feed.title("Mendono - #{@tracker.name}")
    feed.updated((@tracker.last_change.created_at))
    #feed.subtitle("view and change this tracker at #{link_to(@tracker)}", :type => 'html')
    feed.link(:href => url_for(:only_path => false, :format => 'atom'), :rel =>'self')

    for piece in @tracker.changes
      feed.entry(piece, :url => "#{url_for :only_path => false}") do |entry|
        entry.title(piece.text, :type => 'text')
        entry.content(piece.text, :type => 'text')

        entry.author do |author|
          author.name("via Mendono")
        end
      end
    end
  end

