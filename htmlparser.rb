require 'open-uri'
require 'nokogiri'
require 'net/https'
require 'openssl'

class HtmlParserForQuery
    def html_parser url
        title = ""
        body = ""

        begin
            puts "loading #{url}"
            document = open(url)
        rescue Exception => e
            puts "open #{url}. Time Out! PASS"
            return nil
        end

        doc = Nokogiri::HTML(open(url))
        doc.css('title').each do |link|
            title += link.content
        end

        doc.search('//script').each do |node|
            node.children.remove
        end

        doc.css('body').each do |link|
            body += link.content
        end
        body.gsub!(/[\s]+/, " ")

        return title, body
    end


    def https_open url = nil

        https = Net::HTTP.new('encrypted.google.com',443)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        if File.exists?('doc/curl-ca-bundle.crt') then
            puts "load..."
            https.ca_file = 'doc/curl-ca-bundle.crt'
        end
        https.request_get('/')
    end

=begin
    def https_open url = nil
        uri = URI(url)

        begin
            Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https').start do |http|
                request = Net::HTTP::Get.new uri.require_uri

                response = http.request request
            end
        rescue Timeout::Error => e
            puts "oh,no"
        end
        response
    end
=end
end
