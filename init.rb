#!ruby -w
#encoding = utf-8
#

class Level_store
    attr_reader  :perfect
    attr_reader  :excellent
    attr_reader  :good

    def initialize
        @perfect = []
        @excellent = []
        @good = []
    end

    def add level, url
        level_sym = level.to_sym

        array_to_add = case
                       when level_sym == :Perfect then @perfect
                       when level_sym == :Excellent then @excellent
                       when level_sym == :Good then @good
                       else
                           return nil
                       end
        return nil if array_to_add.length >= 10
        array_to_add << url
        return array_to_add.length
    end
end

query_hash = {}
File.new(ARGV[0],"r").each_line do |query|
    query_member = query.split(/\t/)
    query_member[2][-1] = ''
    query_hash.store(query_member[0].to_sym, query_member[2])
end

judgement_hash = {}
File.new(ARGV[1],"r").each_line do |judgement|
    judgement_member = judgement.split(/\t/)
    query_id = judgement_member[1].to_sym
    if query_hash.has_key? query_id then
        judgement_hash.store(query_id, Level_store.new ) if !(judgement_hash.has_key? query_id)
        judgement_hash[query_id].add judgement_member[3], judgement_member[4]
    end
end

outstream = File.new(ARGV[2],"w")

query_hash.each_key do |query_id|
    outstring_head = query_id.to_s + "\t" + query_hash[query_id]

    judgement_hash[query_id].perfect.each do |url|
        outstring = outstring_head + "\tperfect\t" + url
        outstream.write outstring + "\n"
    end

    judgement_hash[query_id].excellent.each do |url|
        outstring = outstring_head + "\texcellent\t" + url
        outstream.write outstring + "\n"
    end

    judgement_hash[query_id].good.each do |url|
        outstring = outstring_head + "\tgood\t" + url
        outstream.write outstring + "\n"
    end
end

outstream.close
