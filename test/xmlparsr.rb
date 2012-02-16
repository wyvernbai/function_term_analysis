require 'nokogiri'

doc = Nokogiri::HTML.parse(<<-eohtml)
<html>
    <head>
      <title>Hello World</title>
    </head>
    <body>
        <h1>This is an awesome document</h1>
        <p>
            I am a paragraph
            <a href="http://google.ca">I am a link</a>
        </p>
    </body>
</html>
eohtml

###
# Search for nodes by css
doc.css('p').each do |a_tag|
    puts a_tag.content
end

####
# Search for nodes by xpath
doc.xpath('//p/a').each do |a_tag|
    puts a_tag.content
end

####
# Or mix and match.
doc.search('//p/a', 'p > a').each do |a_tag|
    puts a_tag.content
end

###
# Find attributes and their values
doc.search('a').first['href']
