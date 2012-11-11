task :restore do
  txt = open('tasks/oqfc.html').read
  regex = /"\/entry\/(\d+)">([^<]+)<.*\n.*\n.*\n.*<small>.+(\d\d\/\d\d\/\d{4}).*\n.*\n.*\n.*\n.+Baseado em (\d{1,3}) votos.">(-?\d{1,3})/i

  matches = txt.scan(regex)

  matches.each do |id_str, text, date_str, total_str, score_str|
    total_votes = total_str.to_i
    score = score_str.to_i
    down_votes = (total_votes - score) / 2
    up_votes = (total_votes - down_votes)
    date = DateTime.strptime(date_str, "%d/%m/%Y")

    puts id_str
    #puts date.strftime("%d/%m/%Y")

    res = Entry.create(:id => id_str, 
                       :text => text,
                       :created_at => date,
                       :vote_count => total_votes,
                       :up_vote_count => up_votes,
                       :down_vote_count => down_votes,
                       :vote_score => score)

    unless res
      puts ">> #{res.errors.full_messages}"
    end
  end

  puts "DONE"
end
