# Taken from official trunk atom_feed_helper.rb
# Monkey patch because we need the schema date support - NOW.
# Remove monkeypatch as soon as rails > 2.0.2 comes out.
module ActionView
  module Helpers #:nodoc:
    module AtomFeedHelper
      def atom_feed(options = {}, &block)
        if options[:schema_date]
          options[:schema_date] = options[:schema_date].strftime("%Y-%m-%d") if options[:schema_date].respond_to?(:strftime)
        else
          options[:schema_date] = "2005" # The Atom spec copyright date
        end
        
        xml = options[:xml] || eval("xml", block.binding)
        xml.instruct!

        feed_opts = {"xml:lang" => options[:language] || "en-US", "xmlns" => 'http://www.w3.org/2005/Atom'}
        feed_opts.merge!(options).reject!{|k,v| !k.to_s.match(/^xml/)}

        xml.feed(feed_opts) do
          xml.id("tag:#{request.host},#{options[:schema_date]}:#{request.request_uri.split(".")[0]}")      
          xml.link(:rel => 'alternate', :type => 'text/html', :href => options[:root_url] || (request.protocol + request.host_with_port))
          xml.link(:rel => 'self', :type => 'application/atom+xml', :href => options[:url] || request.url)
          
          yield AtomFeedBuilder.new(xml, self, options)
        end
      end


      class AtomFeedBuilder
        def initialize(xml, view, feed_options = {})
          @xml, @view, @feed_options = xml, view, feed_options
        end

        def updated(date_or_time = nil)
          @xml.updated((date_or_time || Time.now.utc).xmlschema)
        end

        def entry(record, options = {})
          @xml.entry do 
            @xml.id("tag:#{@view.request.host},#{@feed_options[:schema_date]}:#{record.class}/#{record.id}")

            if options[:published] || (record.respond_to?(:created_at) && record.created_at)
              @xml.published((options[:published] || record.created_at).xmlschema)
            end

            if options[:updated] || (record.respond_to?(:updated_at) && record.updated_at)
              @xml.updated((options[:updated] || record.updated_at).xmlschema)
            end

            @xml.link(:rel => 'alternate', :type => 'text/html', :href => options[:url] || @view.polymorphic_url(record))

            yield @xml
          end
        end

        private
          def method_missing(method, *arguments, &block)
            @xml.__send__(method, *arguments, &block)
          end
      end
    end
  end
end
