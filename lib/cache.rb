require 'digest/md5'
require 'fileutils'
require 'time'

require 'net/http'

class FileCache
    ###Uses a local directory as a store for cached files.
    #Not really safe to use if multiple threads or processes are going to 
    #be running on the same cache.
    
    def initialize(path, maxage=60 * 1)
        @path = path
        @maxage = maxage
        FileUtils.makedirs(@path) unless File.exists? @path
    end

    def get(key, maxage=@maxage)
        cacheFullPath = File.join(@path, Digest::MD5.hexdigest(key))
        begin
            data = File.read(cacheFullPath)
            print "Hit for #{key}"
            
            _,timestamp, value = data.match(/(.*?)\n--\n\n(.*)/m).to_a
            timestamp = Time.rfc822(timestamp)
            
            now = Time.now
            
            raise "Should never ever happen." if timestamp > now
            
            age = now-timestamp
            if age < maxage
            	puts " is Fresh (#{age}s old)."
            	return value
            else
            	puts " is STALE (#{age}s old)."
            	return nil
            end
        rescue Exception => e
            puts "MISS for #{key} and #{e}"
            return nil
        end
        
        nil
    end

    def set(key, value)    
        cacheFullPath = File.join(@path, Digest::MD5.hexdigest(key))
        f = File.new(cacheFullPath,  "w+")
        f.write(Time.now.rfc822 + "\n--\n\n" + value)
        f.close()
    end

    def delete(key)
        cacheFullPath = File.join(@path, Digest::MD5.hexdigest(key))
        FileUtils.rm(cacheFullPath) if File.exists?(cacheFullPath)
        
    end
end

#c = FileCache.new('hooosa')
#c.set("hahaaa", "blaaaa")

def f(uri, cache=nil)
  resp = Net::HTTP.get_response(URI.parse(uri))
  cache.set(uri, resp.body) if cache
end


#f("http://www.better-idea.org", c)

#puts c.get("http://www.better-idea.org")
#puts " aaaaaaaaaaa \n" * 4
#puts c.get("http://www.better-")
