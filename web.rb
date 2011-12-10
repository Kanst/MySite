# encoding: utf-8

require 'sinatra'
require 'redis'
require 'unicode_utils/downcase'
require 'digest/sha2'


def get_title(title = @title)
  
  if @title == nil
   @title1 = 'Страница не найдена'
      erb :ru_404  
  end
  
end

def time()
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
end
get '/' do 
	get_title()
  time()
	erb :index
end

post '/' do
@login = params[:login]
@password = params[:password]
if params[:reg]
  hash_redis(@login,@password)
  time()
  erb :index
else
  if params[:vhod]
    redis_hash(@login,@password)
    time()
    erb :index
  end
end
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
  @name = params[:name]
  @text = params[:text]
  erb :input
end

post '*/input/:title' do
  input = Redis.new
  @title = params[:title]
  @name = params[:name]
  @text = params[:text]
  
  if params[:sm]
    erb :input
  else 
    if params[:go]
      input.set "#{@title}:name", "#{@name}" 
      input.set "#{@title}:text", "#{@text}" 
      erb :done
    else
     erb :ru_404
   end
  end
end

get '*/edit/:title' do 
  edit = Redis.new
  @title = params[:title]
  @text = edit.get "#{@title}:text"
  @name = edit.get "#{@title}:name"
  erb :edit
end

post '*/edit/:title' do
  edit = Redis.new
  @title = params[:title]
  @text = edit.get "#{@title}:text"
  @name = edit.get "#{@title}:name"
  if params[:sm1]
    erb :edit
  else 
    if params[:go1]
      edit.set "#{@title}:name", "#{params[:name]}" 
      edit.set "#{@title}:text", "#{params[:text]}"  
      erb :done2
    else
     erb :ru_404
   end
  end
end

def in_basa(knigaa)
  prov = Redis.new
  @bookss = prov.get "#{knigaa}"
  if @bookss == nil
    @bookss = "Запрошенная книга не существует или не добавлена"
    erb :spisok_ST
  else
    if params[:kniga] == "spisok_ST"
      @bookss = prov.get "spisok_ST"
      erb :spisok_ST
    else
      @bookss_name = prov.get "#{knigaa}:name"
      @bookss_text = prov.get "#{knigaa}:text"
      erb :antonacia
    end
  end
end

get '/books' do
  erb :books
end

get '/books/:kniga' do
 
    in_basa(params[:kniga])
    
end

get '/products' do
  erb :products
end


def hash_redis(log , passwd)
  @log=log
  @passwd=passwd
if ((@log != nil ) or  (@passwd != nil))
user = Redis.new
salt = SecureRandom.urlsafe_base64
hash = Digest::SHA2.hexdigest(passwd + salt)
salt_prov = user.get "users:#{log}:salt"
hash_prov = user.get "users:#{log}:hash"
  if (hash_prov == nil)
    user.set "users:#{log}:salt","#{salt}"
    user.set "users:#{log}:hash", "#{hash}"
    @error = "Регистрация успешна"
   else
     @error = "Пользователь с таким именем уже зареген"
   end 
else
 @error = "Логин или пароль не введены"
end

end

def redis_hash(log , passwd)
user = Redis.new
@log=log
@passwd=passwd
pro_salt = user.get "users:#{log}:salt"
pro_hash = user.get "users:#{log}:hash"
if (pro_salt != nil) and (pro_hash != nil)
  user = Redis.new
  salt = user.get "users:#{log}:salt"
  hash = Digest::SHA2.hexdigest(passwd + salt)
  hash_prov = user.get "users:#{log}:hash"
  if hash == hash_prov
    @error = "Вход выполнен"
  else
    @error = "Пароль неверный"
  end
else
  @error = "Пользователь несуществует" 
end
end  