require 'csv'
require 'securerandom'
require 'uuidtools'

module Utilities
  module GenerateData
    class << self
      #description: create a GUID
      #example: Utilities::GenerateData.get_guid
      def get_guid
        UUIDTools::UUID.timestamp_create().to_s
      end

      def get_string_by_length(length=8)
        t = SecureRandom.base64(8).gsub("/","a").gsub(/[=+$]/,"a")
        t.ljust(length,t).slice(0..length-1)
      end

      def get_alphabet_string_by_length(length)
        str = ""
        length.times{str<<(Random.new.rand(36).to_s(36))}
        return str
      end

      def get_number_string_by_length(length)
        str = ""
        length.times{str<<(rand(9)+1).to_s}
        return str
      end

      def get_number_between_min_and_max(minDigit, maxDigit)
        Random.new.rand(minDigit..maxDigit)
      end

      def get_special_char_string_by_length(length)
        t = ["!","#","$","^","{","}","-","_","=","~","|","."].sort_by{rand} [0,length].join
        t.ljust(length,t)
      end

      def get_phone_number()
        phone_area = Random.new.rand(900..920)
        phone_prefix = Random.new.rand(100..999)
        phone_suffix = Random.new.rand(1000..9999)
        phone = "1-#{phone_area}-#{phone_prefix}-#{phone_suffix}"
        phone
      end

      def get_random_email()
        get_string_by_length(8) + "@null.activenetwork.com"
      end

      #description: generate the person info by time stamp
      #example: Utilities::GenerateData.get_person_info_by_timestamp
      def get_person_info_by_timestamp
        person=Hash.new
        random_code = Time.now.strftime("%Y%m%d%H%M%S")
        person[:firstName]="AutoF#{random_code}"
        person[:lastName]="AutoL#{random_code}"
        person[:email]="Email#{random_code}@null.activenetwork.com"
        person[:gender]="MALE"
        person[:birthday]="1980-10-10"
        person
      end

      def get_user_last_name(prefix="")
        prefix.empty? ? "LN#{get_string_by_length}" :  "#{prefix}#{get_string_by_length}"
      end

      def get_user_first_name(prefix="")
        prefix.empty? ? "FN#{Time.now.strftime("%Y%m%d%H%M%S")}" :  "#{prefix}#{Time.now.strftime("%Y%m%d%H%M%S")}"
      end

      def get_user_name_and_email_hash
        user_data = Hash.new("user_data")
        user_data["first_name"] = get_user_first_name
        user_data["last_name"] = get_user_last_name
        user_data["email"] = "#{user_data["first_name"]}_#{get_string_by_length}@null.activenetwork.com"
        user_data
      end

      def get_user(locale='US')
        file = "#{File.dirname(__FILE__)}/data/#{locale.downcase}_profile.csv"
        rows =CSV.read(file)
        header = rows[0]
        data = rows[rand(3000)+1]
        temp = Hash.new
        header.each_index do |index|
          temp[header[index]] = data[index]
        end
        temp['FirstName']="FN#{Time.now.strftime("%Y%m%d%H%M%S")}"
        temp['LastName']="LN#{get_string_by_length}"
        temp['MiddleName']="M"
        temp['FullName'] = "#{temp['FirstName']} #{temp['MiddleName']} #{temp['LastName']}"
        temp['Email']="#{temp['FirstName']}.#{temp['LastName']}@null.activenetwork.com"
        temp['Birthday']= (Time.now-rand(3600*70*24*365)).strftime("%Y-%m-%d")
        return temp
      end

      def get_user_adult(locale='US')
        profile = get_user(locale)
        profile['Birthday']= (Time.now-rand(3600*42*24*365)-18*24*365*3600).strftime("%Y-%m-%d")
        return profile
      end

      def get_user_child(locale='US')
        profile = get_user(locale)
        profile['Birthday']=(Time.now-rand(3600*18*24*365)).strftime("%Y-%m-%d")
        return profile
      end
    end
  end
end
