# encoding: utf-8

require 'sinatra'
require 'redis'
require 'unicode_utils/downcase'
require 'digest/sha2'


  enable :sessions


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
      else
        if params[:out] 
          session[:login] = nil
          session[:token] = nil
          time()
          erb :index
        end
      end
    end
end

get '*/input/:title' do 
  @title = params[:title]
  @name = params[:name]
  @text = params[:text]
  prov_admin(session[:login])
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
      input.set "#{@title}", "#{@title}" 
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
      edit.set "#{@title}", "#{params[:title]}" 
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
      @bookss = prov.get "spisok_ST:text"
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

post '/books' do
@login = params[:login]
  @password = params[:password]
    if params[:reg]
      hash_redis(@login,@password)
      time()
      erb :books
    else
      if params[:vhod]
        redis_hash(@login,@password)
        time()
        erb :books
      else
        if params[:out] 
          session[:login] = nil
          time()
          session[:token] = nil
          erb :books
        end
      end
    end
end

get '/books/:kniga' do
  in_basa(params[:kniga])   
end

get '/products' do
  erb :products
end

post '/products' do
@login = params[:login]
  @password = params[:password]
    if params[:reg]
      hash_redis(@login,@password)
      time()
      erb :products
    else
      if params[:vhod]
        redis_hash(@login,@password)
        time()
        erb :products
      else
        if params[:out] 
          session[:login] = nil
          session[:token] = nil
          erb :products
        end
      end
    end
end



def hash_redis(login , passwd)
  @log=login
  @passwd=passwd
    if (login.length > 3) and (passwd.length > 3)
      user = Redis.new
      salt = SecureRandom.urlsafe_base64
      hash = Digest::SHA2.hexdigest(passwd + salt)
      salt_prov = user.get "users:#{login}:salt"
      hash_prov = user.get "users:#{login}:hash"
        if (hash_prov == nil)
          user.set "users:#{login}:salt","#{salt}"
          user.set "users:#{login}:hash", "#{hash}"
          @error = "Регистрация успешна"
        else
           @error = "Пользователь с таким именем уже зареген"
        end 
    else
       @error = "Логин или пароль не введены(или не соблюдены условия)"
    end
end

def redis_hash(login , passwd)
  user = Redis.new
  @log=login
  @passwd=passwd
  pro_salt = user.get "users:#{login}:salt"
  pro_hash = user.get "users:#{login}:hash"
    if (pro_salt != nil) and (pro_hash != nil)
      user = Redis.new
      salt = user.get "users:#{login}:salt"
      hash = Digest::SHA2.hexdigest(passwd + salt)
      hash_prov = user.get "users:#{login}:hash"
        if hash == hash_prov
          #if (user.get "users:#{login}:token" == nil)
            token = Digest::SHA2.hexdigest(hash_prov)
            session[:login] = params[:login] 
            session[:token] = token 
            user.set "users:#{login}:token", "#{token}"
          #end
          @error = "Вход выполнен"
          #redirect '/'
        else
          @error = "Пароль неверный"
        end
    else
      @error = "Пользователь несуществует" 
    end
end  


def prov_admin(login_prov)
  user = Redis.new
  proverka = user.get "users:#{login_prov}:admin"
    if proverka == "yes"
      prov_admin = true
    else
      prov_admin = false
    end
end
