# i18n monkeypatch taken from
# http://code.whytheluckystiff.net/hpricot/ticket/137

def Hpricot.uxs(str)
  str.to_s.
        gsub(/&(\w+);/) { [Hpricot::NamedCharacters[$1] || ??].pack("U*") }.
        gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }
end

