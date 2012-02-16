#!ruby -w
#encodind = utf-8
#

ndcg_file = "..\\data\\IE01_QueryId_RawQuery.txt.ndcg"
query_file = "..\\data\\IE01_QueryId_RawQuery.txt"

queryID_ndcg = {}
File.new(ndcg_file, "r").each_line do |ndcg|
    if !(ndcg =~ /^$/) then
        ndcg_array = ndcg.split(/\t/)
        queryID_ndcg.store(ndcg_array[0].to_i, ndcg_array[1].to_f)
    end
end

outstream = File.new(ARGV[1],"w")

function_word_file = ARGV[0]
IO.read(function_word_file).split(/\n/).each do |term_line|
    result_hash = {}
    term = term_line.split(/,/)
    outstream.write "#{term}\n"
    term_num = term.size
    hit_count = 0
    query_length = 0.0
#    print "terms:\t#{term}\n\n"

    File.new(query_file, "r").each_line do |query|
        query_array = query.split(/[\s]+/)
        query_num = query_array.size
        res = catch :term_hit do
            (1..query_num - 1).each do |index|
                (0..term_num - 1).each do |term_index|
                    reg = Regexp.new("^#{term[term_index]}$", Regexp::IGNORECASE)
                    throw :term_hit,query_num - 1 if query_array[index] =~ reg
                end
            end
            false
        end
        if res != false then
            result_hash.store(query.split(/\t/)[0].to_i, query.split(/\t/)[1])
            hit_count += 1
            query_length += res
        end
    end

    ndcg_sum = 0.0
    result_hash.each do |key, value|
        ndcg = queryID_ndcg[key]
        ndcg_sum += ndcg
        outstream.write "#{key}\t#{ndcg}\t#{value}"
    end

#    puts "#{term}\t#{hit_count}\t#{ndcg_sum / hit_count}\t#{query_length / hit_count}"
    outstream.write "hit num:\t#{hit_count}\n"
    outstream.write "ndcg_average:\t#{ndcg_sum / hit_count}\n"
    outstream.write "average query length:\t#{query_length / hit_count}\n"
    outstream.write "####################################################\n\n"
end

outstream.close
