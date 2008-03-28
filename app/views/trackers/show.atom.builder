  atom_feed(:root_url => url_for(@tracker)) do |feed|
    feed.title("Tracker for #{@tracker.uri}")
    feed.updated((@tracker.last_change.created_at))
    feed.subtitle("hossa")

    for piece in @tracker.changes
      feed.entry(piece, :url => "#{url_for(@tracker)}") do |entry|
        entry.title(piece.text_raw, :type => 'html')
        entry.content(piece.text_raw, :type => 'html')

        entry.author do |author|
          author.name("Extracted from #{@tracker.uri}")
        end
      end
    end
  end

