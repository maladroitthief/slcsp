require 'csv'

# plan_id, state, metal_level, rate, rate_area
plans_csv = CSV.read("plans.csv")
# zipcode, state, county_code, name, rate_area
zips_csv = CSV.read("zips.csv")
# zipcode, rate
slcsp_csv = CSV.read("slcsp.csv")

zips_hash = {}
zips_csv.each_with_index do |val, index|
  next if index == 0

  zips_hash[val[0]] = val
end

plans_hash = {}
plans_csv.each_with_index do |val, index|
  next if index == 0
  next if val[2] != 'Silver'

  key = "#{val[1]}#{val[4]}"
  if plans_hash[key].nil?
    plans_hash[key] = [ val ]
  else
    plans_hash[key] = plans_hash[key].append(val)
  end
end

memo = {}
CSV.open("slcsp.csv", "w") do |csv|
  slcsp_csv.each_with_index do |row, index|
    if index == 0
      csv << row
      puts "#{row[0]},#{row[1]}"
      next
    end

    zip = zips_hash[row[0]]
    if zip.nil?
      csv << row
      puts "#{row[0]},#{row[1]}"
      next
    end

    key = "#{zip[1]}#{zip[4]}"
    if !memo[key].nil?
      row[1] = memo[key]
      csv << row
      puts "#{row[0]},#{row[1]}"
      next
    end

    plan = plans_hash[key]
    if plan.nil?
      csv << row
      puts "#{row[0]},#{row[1]}"
      next
    end

    plan = plan.sort { |a, b| a[3].to_f <=> b[3].to_f }
    if plan.length == 1
      memo[key] = plan[0][3]
    else
      memo[key] = plan[1][3]
    end

    row[1] = memo[key]
    csv << row
    puts "#{row[0]},#{row[1]}"
  end
end
