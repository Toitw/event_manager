require "csv"
require 'google/apis/civicinfo_v2'
require 'erb'


def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zip)
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
    begin
      civic_info.representative_info_by_address(
        address: zip,
        levels: 'country',
        roles: ['legislatorUpperBody', 'legislatorLowerBody']
      ).officials
    rescue
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
end

def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_home_phone(homephone)
    clean_number = homephone.gsub(/[^\d]/, "")
    if clean_number[0] != 1 && clean_number.length == 11
        clean_number = "0000000000"
    elsif clean_number.length < 10
        clean_number = "0000000000"
    elsif clean_number.length > 10 && clean_number[0] == 1
        clean_number[0..9]
    else
        clean_number
    end
end

puts "Event Manager Initialized!"

template_letter = File.read("form_letter.html")
erb_template = ERB.new template_letter

contents = CSV.open(
    "event_attendees.csv",
    headers: true,
    header_converters: :symbol
)
contents.each do |row|
    id = row[0]
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    home_phone = clean_home_phone(row[:homephone])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id, form_letter)
end