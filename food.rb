#!/usr/bin/env ruby
require 'net/https'
require 'json'

class String
    def is_i?
       !!(self =~ /\A[-+]?[0-9]+\z/)
    end
end
def winsize
 require 'io/console'
 IO.console.winsize
 rescue LoadError
 [Integer(`tput li`), Integer(`tput co`)]
end
rows, cols = winsize

column = ((cols-1)/5).floor*2

def getWeekDay (time)
  if time.monday? 
    return 0
  elsif time.tuesday? 
    return 1
  elsif time.wednesday? 
    return 2
  elsif time.thursday? 
    return 3
  elsif time.friday? 
    return 4
  elsif time.saturday? 
    return 5
  elsif time.sunday? 
    return 6
  end
end

def getWeek (time)
  dayone = Time.new(time.year)
  difference = ((time - dayone)/60/60/24).floor
  week = ((difference + getWeekDay(dayone))/7).floor+1
  return week
end

def https (uri)
  url = URI.parse(uri)
  response = Net::HTTP.start(url.host, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
    http.get url.request_uri, 'User-Agent' => 'MyLib v1.2'
  end
  case response
  when Net::HTTPRedirection
    # repeat the request using response['Location']
  when Net::HTTPSuccess
    return response.body
  else
    # response code isn't a 200; raise an exception
    response.error!
  end
end

def getFood (year, week)
  data = https "https://api.uwaterloo.ca/v2/foodservices/#{year}/#{week}/menu.json?key=e327b44fb6bd3c3467e4792ddb6e42e9"
  return JSON.parse data
end

def convertDate (time)
  if getWeekDay(time)>4
    return time+24*60*60*(7-getWeekDay(time))
  else
    return time
  end
end

def blank (n)
  if n>=0
   return (" " * n)
  else 
    return ""
  end
end

def output (data, column, time)
  nameweek = ["Monday", "Tuesday", "Wednesay", "Thursday", "Friday", "Satruday", "Sunday"]
namemonth = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
  puts "========#{nameweek[getWeekDay(time)]}, #{namemonth[time.month-1]} #{time.day}========"
puts "|#{blank(column/2-2)}|Lunch#{blank(column-"Lunch".length)}|Dinner#{blank(column-"Dinner".length)}"
for i in 0..data.length-1
  for i2 in 0..[data[i]['menu'][getWeekDay(time)]['meals']['lunch'].length, data[i]['menu'][getWeekDay(time)]['meals']['dinner'].length].max-1
    if i2==0
      print "|#{data[i]['outlet_name'][0..column/2]}#{blank(column/2-data[i]['outlet_name'].length-2)}"
      if data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2] != nil
        print "|#{data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][0..column-1]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'].length)}"
      else
        print "|#{blank(column-1)}"
      end
      if data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2] != nil
        print "|#{data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][0..column-1]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'].length)}"
      else
        print "|#{blank(column-1)}"
      end
    else
      print "|#{blank(column/2-2)}"
      if data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2] != nil
        print "|#{data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][0..column-1]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'].length)}"
      else
        print "|#{blank(column-1)}"
      end
      if data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2] != nil
        print "|#{data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][0..column-1]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'].length)}"
      else
        print "|#{blank(column-1)}"
      end
    end
    puts ""
    if data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2] != nil && data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2] != nil
      if data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'].length>column-1 && data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'].length>column-1
        print "|#{blank(column/2-2)}|#{data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][column..column*2-2]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][column..column*2-2].length)}|#{data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][column..column*2-2]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][column..column*2-2].length)}"
        puts ""
      elsif data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'].length>column-1
        print "|#{blank(column/2-2)}|#{data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][column..column*2-2]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][column..column*2-2].length)}|#{blank(column-1)}"
        puts ""
      elsif data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'].length>column-1
        print "|#{blank(column/2-2)}|#{blank(column)}|#{data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][column..column*2-2]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][column..column*2-2].length)}"
        puts ""
      end
    elsif data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2] != nil
      if data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'].length>column-1
        print "|#{blank(column/2-2)}|#{data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][column..column*2-2]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['lunch'][i2]['product_name'][column..column*2-2].length)}|#{blank(column-1)}"
        puts ""
      end
    elsif data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2] != nil
      if data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'].length>column-1
        print "|#{blank(column/2-2)}|#{blank(column)}|#{data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][column..column*2-2]}#{blank(column-data[i]['menu'][getWeekDay(time)]['meals']['dinner'][i2]['product_name'][column..column*2-2].length)}"
        puts ""
      end
    end 
  end
end
end


command = ARGV.shift
case command
when "today"
  time = convertDate(Time.now)
when "tomorrow"
  time = convertDate(Time.now+24*60*60*1)
when "yesterday"
  time = convertDate(Time.now-24*60*60*1)
when "week"
  time = convertDate(Time.now)
when "help"
  puts "Possible arguements: today, tomorrow, yesterday, week, date (format: yymmdd)"
when nil
  time = convertDate(Time.now)
else
  if command.is_i?
    time = convertDate(Time.new(2000+(command.to_i/10000).floor, (command.to_i/100).floor.modulo(100),command.to_i.modulo(100)))
  else
    time = convertDate(Time.now)
  end
end

repo_info = getFood(time.year, getWeek(time))
data = Array.new(){Array.new()}

for i in 0..repo_info['data']['outlets'].length-1
  data.push(repo_info['data']['outlets'][i])
end

if command != "week"
  output(data, column, time)
else
  for i in 0..4
    output(data, column, time+(i-getWeekDay(time))*24*60*60)
  end
end
#puts https('https://reserve.studentcarshare.ca/webservices/index.php/WSUser/WSRest')
