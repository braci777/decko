class ConvertPipesToDashes < ActiveRecord::Migration
  def self.up


    # this is code we used to convert one postgres database.  Since we don't yet have a great
    # way to do consistent pattern matching in a safe, database-agnostic way (maybe in 0.9?),
    # we're leaving this out of the main migration.
=begin

    cards = Card.find_by_sql(
    "SELECT DISTINCT  t0.* FROM cards t0  WHERE (t0.trash='f' AND t0.name LIKE '%'||E'|'||'%')"
    ) 
    cards=[]
    cards.each_with_index do |c,i| 
      oldname=c.name; c.name = c.name.gsub('|', '-'); puts "#{i} #{oldname}->#{c.name}"; 
      c.confirm_rename=true; c.update_link_ins=true; begin c.save!; rescue Exception=>e; puts e.message; end; 
    end

=end

  end

  def self.down
  end
end
