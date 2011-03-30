get '/sass/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass params[:name].to_sym
end

get '/coffeescript/:name.js' do
  coffee param[:name].to_sym
end