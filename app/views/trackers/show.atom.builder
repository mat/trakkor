require 'atom_monkeypatch'

  atom_feed(:root_url => url_for(:only_path => false)) do |feed|
    feed.title("Trakkor - #{@tracker.name}", :type => 'text')
    feed.updated((@tracker.last_change.created_at))
    feed.subtitle("This tracker observes <a href='#{@tracker.uri}'>#{@tracker.uri}</a>.<br /> View and change tracker settings at <a href='#{url_for :only_path => false}'>#{@tracker.name}</a>", :type => 'html')
    feed.link(:href => url_for(:only_path => false, :format => 'atom'), :rel =>'self')

    for piece in @tracker.changes
      feed.entry(piece, :url => "#{url_for :only_path => false}") do |entry|
        entry.title(piece.text, :type => 'text')
        entry.content(piece.text, :type => 'text')

        entry.author do |author|
          author.name("via Trakkor")
        end
      end
    end
  end

