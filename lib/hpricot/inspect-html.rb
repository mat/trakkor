require 'pp'


HTML_ESCAPE = {'&'=>'&amp;', '"'=>'&quot;', '>'=>'&gt;', '<'=>'&lt;'}
def html_escape(s)
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
end


module Hpricot
  # :stopdoc:
  class Elements
    def pretty_print(q)
      q.object_group(self) { super }
    end
    alias inspect pretty_print_inspect
  end

  class Doc
    def pretty_print(q)
      q.object_group(self) { @children.each {|elt| q.breakable; q.pp elt } }
    end
    alias inspect pretty_print_inspect
  end

  class Elem
    def pretty_print(q)
      if empty?
        q.group(1) {
          q.breakable; q.pp @stag
        }
      else
        q.group(1) {
          q.breakable; q.pp @stag
          if @children
            @children.each {|elt| q.breakable; q.pp elt }
          end
          if @etag
            q.breakable; q.pp @etag
          end
        }
      end
    end
    alias inspect pretty_print_inspect
  end

  module Leaf
    def pretty_print(q)
      q.group(1) {
        if rs = @raw_string
          rs.scan(/[^\r\n]*(?:\r\n?|\n|[^\r\n]\z)/) {|line|
            q.breakable
            q.pp line
          }
        elsif self.respond_to? :to_s
          q.breakable
          q.text(html_escape(self.to_s))
        end
      }
    end
    alias inspect pretty_print_inspect
  end

  class STag
    def pretty_print(q)
      q.group(1, '&lt;', '&gt;') {
        q.text(html_escape(@name))

        if @raw_attributes
          @raw_attributes.each {|n, t|
            q.breakable
            if t
              q.text(html_escape("#{n}=\"#{Hpricot.uxs(t)}\""))
            else
              q.text(html_escape(n))
            end
          }
        end
      }
    end
    alias inspect pretty_print_inspect
  end

  class ETag
    def pretty_print(q)
      q.group(1, '&lt;', '&gt;') {
        q.text(html_escape(@name))
      }
    end
    alias inspect pretty_print_inspect
  end

  class Text
    def pretty_print(q)
      q.text(html_escape("#{@content.strip}"))
    end
  end

  class BogusETag
    def pretty_print(q)
      q.group(1) {
        if rs = @raw_string
          q.breakable
          q.text(html_escape(rs))
        else
          q.text "&lt;/#{@name}&gt;"
        end
      }
    end
  end
  # :startdoc:
end

