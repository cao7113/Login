class User < ActiveRecord::Base
  
  #添加非空验证
  validates_presence_of :name, :pwd, :key
  #要求名字唯一
  validates_uniqueness_of :name 
  #长度小于20
  validates_length_of :name, :maximum  => 19
  #不包括@
  validates_format_of :name, :with => /\A[^@]{1,19}\z/, :message => "不允许有@"
  #pwd长度大于4
  validates_length_of :pwd, :minimum => 5
  
  #添加虚拟属性，用户输入的密码：raw_pwd, 且要求非空
  attr_accessor :raw_pwd
#  validates_presence_of :raw_pwd  
  
  #mail，非空
  validates_presence_of :mail
  #唯一
  validates_uniqueness_of :mail  
  
end
