#!ruby -w
#encoding = utf-8
#

require './htmlparser.rb'

def init
    puts "init"
    @func_term_fre_title = 0
    @func_term_fre_body = 0
    @other_term_fre_title = 0
    @other_term_fre_body = 0
    @other_term_count = 0

end

def output_result outstream, outstream_detail
    old_judge_member = @old_judgement.split(/\t|\n/)
    temp_mark = false
    old_judge_member[1].split(/ /).each do |term|
        @func_reg.each do |reg|
            temp_mark = true if term =~ reg
        end
        @other_term_count += 1 if !temp_mark
        temp_mark = false
    end

    p @other_term_count
    outstring = old_judge_member[0] + "\t" + old_judge_member[1] + "\t#{@other_term_fre_title.to_f / @other_term_count}\t#{@other_term_fre_body.to_f / @other_term_count}\t#{@func_term_fre_title}\t#{@func_term_fre_body}\n"
    outstream.write outstring
    outstream_detail.write SPLIT_LINE + outstring + SPLIT_LINE
    init
end

query_id = 0

stop_word_file = "doc/stopwordlist.smart.571.txt"
stop_word = {}

line = 0
File.open(stop_word_file, "r").each_line do |word|
    stop_word.store(word, line += 1)
end

@term_group = ARGV[0].split(/\\/)[-1].split(/\./)[0].split(/_/)
@func_reg = []
@term_group.each do |term|
    @func_reg << Regexp.new("^" + term + "$", Regexp::IGNORECASE)
end
p @term_group
@func_term_fre_title = 0
@func_term_fre_body = 0
@other_term_fre_title = 0
@other_term_fre_body = 0
@other_term_count = 0
mark = false

outstream = File.open(ARGV[1],"w")
outstream_detail = File.open(ARGV[1] + ".detail", "w")
SPLIT_LINE = "#####################################################################\n"

File.open(ARGV[0],"r").each_line do |judgement|
    term_fre_title = []
    term_fre_body = []

    judgement[-1] = ""

    judge_member = judgement.split(/\t|\n/)
    if judge_member[0].to_i != query_id then
        output_result outstream, outstream_detail if query_id != 0
        @old_judgement = judgement
        query_id = judge_member[0].to_i
        init
    end
    title, body = HtmlParserForQuery.new.html_parser(judge_member[3])
    next if title == nil
=begin
    next if count == 9
    count += 1
=end
    judge_member[1].split(/ /).each do |term|
        reg = Regexp.new(term, Regexp::IGNORECASE)
        @func_reg.each do |value|
            if term =~ value then
                puts "get function term: #{term}"
                title_fre = title.scan(reg).size
                body_fre = body.scan(reg).size
                @func_term_fre_title += title_fre
                @func_term_fre_body += body_fre
                term_fre_title << title_fre
                term_fre_body << body_fre
                mark = true
            end
        end

        if mark then
            mark = false
            next
        end

        if stop_word.has_key? term then
            term_fre_title << -1
            term_fre_body << -1
            next
        end

        title_fre = title.scan(reg).size
        body_fre =  body.scan(reg).size

        term_fre_title << title_fre
        term_fre_body << body_fre
        @other_term_fre_title += title_fre
        @other_term_fre_body += body_fre
    end

    outstream_detail.write judgement + "\t#{term_fre_title}\t#{term_fre_body}\n"
end
output_result outstream, outstream_detail

outstream.close
outstream_detail.close

