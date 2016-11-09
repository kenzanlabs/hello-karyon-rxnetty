#
# Cookbook Name:: helloworld
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# This is an example Chef recipe
 
file '/tmp/helloworld.txt' do
  content node['helloworld']['content']
end

