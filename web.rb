# encoding: utf-8

require 'sinatra'
require 'redis'
require 'unicode_utils/downcase'


def get_title(title = @title)
  
  if @title == nil
   @title1 = 'Страница не найдена'
      erb :ru_404  
  end
  
end

get '/' do 
	get_title()
	t0=Time.now
	t1=Time.local(2011,12,29)
	t2=Time.local(2012,01,12)
	sec0=t1-t0
	sec1=sec0.round
	se0=t2-t0
	se1=se0.round
	@dni=(((sec1/60)/60))/24
	@dni2=(((sec1/60)/60))
	@dni3=(((sec1/60)))
	@dn=(((se1/60)/60))/24
	@dn2=(((se1/60)/60))
	@dn3=(((se1/60)))
	erb :index
end

# get '/*' do 
# 	t0=Time.now
# 	t1=Time.local(2011,12,29)
# 	t2=Time.local(2012,01,12)
# 	sec0=t1-t0
# 	sec1=sec0.round
# 	se0=t2-t0
# 	se1=se0.round
# 	@dni=(((sec1/60)/60))/24
# 	@dni2=(((sec1/60)/60))
# 	@dni3=(((sec1/60)))
# 	@dn=(((se1/60)/60))/24
# 	@dn2=(((se1/60)/60))
# 	@dn3=(((se1/60)))
# 	get_title()
	
# end

get '*/input/:title' do 
  @title = params[:title]
  erb :input
end

post '*/input/:title' do
  input = Redis.new
  @title = params[:title]
  @text = params[:text]
  
  if params[:sm]
    erb :input
  else 
    if params[:go]
      input.set "#{@title}", "#{@text}" 
      erb :done
    else
     erb :ru_404
   end
  end
end

get '*/edit/:title' do 
  input = Redis.new
  @title = params[:title]
  @text = input.get params[:title]
  erb :edit
end

post '*/edit/:title' do
  input = Redis.new
  @title = params[:title]
  @text = input.get params[:title]
  if params[:sm1]
    erb :edit
  else 
    if params[:go1]
      input.set "#{@title}", "#{params[:text]}"  
      erb :done2
    else
     erb :ru_404
   end
  end
end

def in_basa()
  prov = Redis.new
  @spisok = prov.get params[:kniga]
  if @spisok == nil
    @spisok = "Запрошенная книга не существует или не добавлена"
  else
    @spisok = prov.get "spisok_ST"
  end
end

get '/books' do
  erb :books
end

get '/books/:kniga' do
  #if params[:kniga] == "spisok_ST"
    in_basa()
    erb :spisok_ST
 # else
 #   in_basa()
 #   erb :spisok_ST
 # end
end

get '/products' do
  erb :products
end

