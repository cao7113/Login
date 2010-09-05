class UsersController < ApplicationController
  
  #处理图像缩略图
  require 'RMagick'
  include Magick
  
  #进入新建用户页面
  def new
    @user=User.new
  end
  
  #根据输入表单创建新用户
  def create
    #获得表单值
    user=User.new(params[:user])
    #10个随机生成的数字
    user.key=""#初值
    10.times do
      user.key<<rand(10).to_s
    end
    #
    user.pwd=Digest::MD5.hexdigest(user.raw_pwd+user.key)   
    
    #添加事务处理
    User.transaction do
      if user.save
        #获取头像并处理
        icon_file=params[:icon_file]
        handel_icon(icon_file, user)     
        
        logger.error("成功创建用户#{user.name}")        
        redirect_to :action=>:index
      else      
        logger.error("创建用户失败")
        flash.now[:notice]="创建用户失败"
        @user=user
        render :action=>:new
      end    
    end    
    
  end
  
  #用户登录功能，根据用户输入的用户名和密码进行判断
  def login_check
    
    #可以按用户名或mail方式登录
    if params[:name].include?('@')
      user=User.find_by_mail(params[:name].strip)
    else
      user=User.find_by_name(params[:name].strip)
    end
    
    if user
      #验证密码
      input_pwd=Digest::MD5.hexdigest(params[:password]+user.key)
      if input_pwd==user.pwd
        #将该用户的id存入Session中
        session[:id]=user.id
        session[:name]=user.name
        #记住我
#        logger.debug("--------------check box value=#{params[:remind_me]}")
        if "1"==params[:remind_me]
#          #设置30天后过期
           cookies[:id]={
             :value=>user.id,
             :expires=>30.days.from_now
           }
           cookies[:safe]={
             :value=>Digest::MD5.hexdigest(user.id.to_s+user.key),
             :expires=>30.days.from_now
           }
           logger.debug("----已经写了‘记住我’cookie")
         else
           logger.debug("----没写‘记住我’cookie")
        end
        render :action=>:login_success#:text=>"登录成功"
      else
        flash.now[:notice]="密码错误"
        render :action=>:login
        return
      end
    else
      #没找到
      flash.now[:notice]="无此用户: #{params[:name]}"
      render :action=>:login
      return
    end    
  end  
  
  #修改用户信息
  def edit
    @user=User.find_by_id(session[:id])
  end
  
  #更新用户信息
  def update
    @user=User.find_by_id(session[:id])
    User.transaction do
      #密码更新
      if params[:user][:raw_pwd].strip!=""
        @user.pwd=Digest::MD5.hexdigest(params[:user][:raw_pwd].strip+@user.key)
      end
      #如上传了头像，重新处理即可，旧文件会被重写
      icon_file=params[:icon_file]
      handel_icon(icon_file, @user)
      
      if @user.update_attributes(params[:user])
        logger.info("更新用户信息成功")
        flash.now[:notice]="更新成功！"
      else
        flash.now[:notice]="更新失败"      
      end
    end   
    
    render :action=>:edit
  end
  
  #退出系统
  def logout
    reset_session
    redirect_to :action=>:index
  end    
  
  #处理头像
  def handel_icon(icon_file, user)
    if !icon_file.nil?
          logger.debug("----icon info, class=#{icon_file.class}, size=#{icon_file.size},
                 type=#{icon_file.content_type.chomp}, original file name=#{icon_file.original_filename}")
          #判断文件大小，转换成位
          icon_size=48*48*32
          #头像文件路径
          today=Time.now
          #获取文件后缀
          file_ext=icon_file.original_filename.split('.').last
          if file_ext.size>0
            file_ext='.'+file_ext
          end
          icon_path="/public/images/#{today.year}/#{today.strftime('%m')}/#{today.strftime('%d')}"
          FileUtils.mkpath(RAILS_ROOT+icon_path)
          icon_full_path=icon_path+"/#{user.id}#{file_ext}"
#          logger.debug("-------path=#{icon_path}")        
          if icon_file.size>icon_size            
            #将文件存储到临时文件
            icon_tmp_path=RAILS_ROOT+icon_path+"/#{user.id}_tmp#{file_ext}"
            File.open(icon_tmp_path, "wb") do |f|
              f.write(icon_file.read)
            end 
           
            #使用Rmagic对临时文件压缩成统一格式            
            pic = ImageList.new(icon_tmp_path)
            thumb = pic.thumbnail(48, 48)
            thumb.write(RAILS_ROOT+icon_full_path)
            #删除临时文件
            File.delete(icon_tmp_path) 
            logger.debug("----头像经过压缩处理")
          else
            #将文件存储到
            File.open(RAILS_ROOT+icon_full_path, "wb") do |f|
              f.write(icon_file.read)
            end            
            logger.info("----按原尺寸大小写了一幅头像")
          end
          #将头像路径更新到数据库中
          user.update_attribute(:icon, icon_full_path)
        end  
  end

end
