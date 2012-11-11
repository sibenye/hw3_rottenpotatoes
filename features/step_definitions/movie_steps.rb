# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
     rotMovies = Movie.create!(movie)
  end
  #flunk "Unimplemented"
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.content  is the entire content of the page as a string.
  regexp = /#{e1}.*#{e2}/m
  page.has_xpath?('//*', :text => regexp)
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

#When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  
#  rating_list.split(/\s/).each do |rating|
#     When %{I uncheck #{rating}}
#     end
#end

Given /I check the following ratings: (.*)/ do |rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  
  rating_list.split(/\s/).each do |rating|
     rating = rating.to_s.gsub(/[\[\]'",]/, '')
     step "I check ratings[#{rating}] checkbox"
     end
end

Given /I uncheck the following ratings: (.*)/ do |rating_list|
  # HINT: use String#split to split up the rating_list, then
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
  
  rating_list.split(/\s/).each do |rating|
     rating = rating.to_s.gsub(/[\[\]'",]/, '')
     step "I uncheck ratings[#{rating}] checkbox"
     end
end



Then /I should see only movies with ratings: (.*)$/ do |rating|
   shouldSee = ''
   shouldNotSee = ''
   uniqRating = Array.new()
   
    ratings_A = rating.split(/\s/)
    ratings_A.each do |ratingcon|
    if (ratingcon != nil && !ratingcon.eql?('')) then
    content = Movie.where("rating = #{ratingcon}").select("title")
    content.each do |rt|
    if (rt != nil && !rt.eql?("")) then
    shouldSee = rt.title
    shouldSee = shouldSee.gsub(/[\[\]"]/, '')
    step %{I should see this #{shouldSee}}
    end
    end
    end
    uniqRating << ratingcon
    end
    

   rating = Movie.select(:rating).uniq
   allRating = Array.new()
   rating.each do |rt|
   allRating = allRating.push(rt.rating)
   end

   movtitle = Array.new()
    if (uniqRating.length != allRating.length) then
    allMovies = Movie.all
   allMovies.each do |m|
   mov_title = m.title
   mov_rating = m.rating
   mov_date = m.release_date
   #movtitle << mov_title.gsub(/[\[\]"]/, '')
   movtitle << ["#{mov_title}", "#{mov_rating}", "#{mov_date}"]
   end 
   assert(page.has_no_table?('movies', :rows => movtitle), "#{movtitle}")
    end
      
end

Then /I should see all of the movies: (.*)/ do |order| 
   if (order.eql?("in no order")) then
   step %{I Check all ratings}
   allMovies = Movie.select("title").all
   allMovies.each do |m|
   movtitle = m.title
   movtitle = movtitle.gsub(/[\[\]"]/, '')
   step %{I should see this #{movtitle}}
   end 
   end

   if (order.eql?("by title")) then
   movtitle = Array.new()
   allMovies = Movie.order("title ASC").all
   allMovies.each do |m|
   mov_title = m.title
   mov_rating = m.rating
   mov_date = m.release_date
   #movtitle << mov_title.gsub(/[\[\]"]/, '')
   movtitle << ["#{mov_title}", "#{mov_rating}", "#{mov_date}"]
   end 
   assert(page.has_table?('movies', :rows => movtitle), "#{movtitle}")
   end

   if (order.eql?("by date")) then
   movtitle = Array.new()
   allMovies = Movie.order("release_date ASC").all
   allMovies.each do |m|
   mov_title = m.title
   mov_rating = m.rating
   mov_date = m.release_date
   #movtitle << mov_title.gsub(/[\[\]"]/, '')
   movtitle << ["#{mov_title}", "#{mov_rating}", "#{mov_date}"]
   end 
   assert(page.has_table?('movies', :rows => movtitle), "#{movtitle}")
   end
end

Then /I should not see a blank movie list/ do
   step %{I UnCheck all ratings}

   row_content = Array.new()
   
   rows = Movie.count
   t_value = ""
   r_value = ""
   d_value = ""
   while rows > 0 do
   row_content << [t_value, r_value, d_value]
   rows -= 1
   end

   assert(page.has_no_table?('movies', :rows => row_content), "#{row_content}")
end

Then /(Un)?Check all ratings/ do |uncheck|
    ratings = Movie.all_ratings
    if(uncheck) then
    step %{I uncheck the following ratings: #{ratings}}
    step %{I press "Refresh"}
    else
    step %{I check the following ratings: #{ratings}}
    step %{I press "Refresh"}
    end

end
