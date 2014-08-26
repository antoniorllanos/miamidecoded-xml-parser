def order_by(integer)
	return "0"*(10-integer.to_s.length)+integer.to_s
end

def order_structure(integer)
	return "0"*(5-integer.to_s.length)+integer.to_s
end

def structure_name(depth,part_count)
	if part_count==2
		return ["PART","ARTICLE"][depth-1]
	elsif part_count==1
		return "PART"
	elsif part_count==3
		return ["PART","CHAPTER"][depth-1]
	else
		return ["PART","CHAPTER","ARTICLE"][depth-1]
	end
end
require 'roman-numerals'
require 'nokogiri'

section_parser=Proc.new do |section,o|
	section.xpath('para|listitem').each do |item|
		if item.name=="listitem"
			prefix=item.xpath('incr')[0].content.strip
			content=item.xpath('content')[0].content.gsub(/&/,"&amp;").strip
			o.write("<section prefix='#{prefix}'>#{content}")
			section_parser.call(item,o)
			o.write("</section>")
		else
			content=item.xpath("text()").to_s.gsub(/[\n\r]/,"").gsub(/\s+/," ").gsub(/&/,"&amp;").strip
			o.write("<section>#{content}")
			section_parser.call(item,o)
			o.write("</section>")
		end
	end
end


f=File.open("raw_dump.xml","r+")
doc=Nokogiri::XML(f)
global_section_count=1
part_count=1
doc.xpath("book/level1").each do |part|
		if part_count==3
			depth=1
							part_name=part.xpath('subtitle[1]')[0].content.gsub(/ /,"_").strip;
							o=File.open("import-data/#{part_name}.xml","w+")
							o.write("<?xml version='1.0' encoding='utf-8'?>\n")
							o.write("<law>\n<structure>\n")
							o.write("<unit label='part' identifier='PART 2' order_by='#{order_structure(part_count)}' level='#{(depth-3).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
							o.write("</structure>\n")
							o.write("<section_number>abc</section_number>\n")
							o.write("<catch_line>#{part.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
							o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
							o.write("<text>")
							o.write("<section>#{part.xpath('title[1]')[0].content.strip+' '+part.xpath('subtitle[1]')[0].content.strip}")
							section_parser.call(part,o)
							o.write("</section>")
							o.write("</text>")
							if(!part.xpath("comment[@note='historynote']").empty?)
								o.write("<history>#{part.xpath("comment[@note='historynote']")[0].content.strip}</history>")
							end							
							o.write("</law>")
							o.close
							global_section_count+=1
		elsif part_count==1
			depth=1
							part_name=part.xpath('subtitle[1]')[0].content.gsub(/ /,"_").strip
							puts part.xpath('subtitle[1]')[0].content
                                                        puts part_name
							o=File.open("import-data/#{part_name}.xml","w+")
							o.write("<?xml version='1.0' encoding='utf-8'?>\n")
							o.write("<law>\n<structure>\n")
							o.write("<unit label='part' identifier='PART 0' order_by='#{order_structure(part_count)}' level='#{(depth-3).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
							o.write("</structure>\n")
							o.write("<section_number></section_number>\n")
							o.write("<catch_line>#{part.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
							o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
							o.write("<text>")
							o.write("<section>#{part.xpath('title[1]')[0].content.strip+' '+part.xpath('subtitle[1]')[0].content.strip}")
							section_parser.call(part,o)
							o.write("</section>")
							o.write("</text>")
							if(!part.xpath("comment[@note='historynote']").empty?)
								o.write("<history>#{part.xpath("comment[@note='historynote']")[0].content.strip}</history>")
							end							
							o.write("</law>")
							o.close
							global_section_count+=1
		else
			depth=1
			chapter_count=1
			part.xpath("level2").each do |chapter|
				depth=2									
				if(!chapter.xpath("level3").empty?)
					article_count=1
					chapter.xpath("level3").each do |article|
						depth=3
						section_count=1
						article.xpath("section").each do |section|
							depth=4
							section_name=section.xpath('title[1]')[0].content.strip.split(" ")[-1].gsub(/\.$/,"").gsub(/ /,"_")
							o=File.open("import-data/#{section_name}.xml","w+")
							o.write("<?xml version='1.0' encoding='utf-8'?>\n")
							o.write("<law>\n<structure>\n")
							o.write("<unit label='part' identifier='#{structure_name(1,part_count)} #{(part_count-1).to_s}' order_by='#{order_structure(part_count)}' level='#{(depth-3).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
							o.write("<unit label='chapter' identifier='#{order_structure(chapter_count)}' order_by='#{order_structure(chapter_count)}' level='#{(depth-2).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip}</unit>\n")
							o.write("<unit label='article' identifier='#{order_structure(article_count)}' order_by='#{order_structure(article_count)}' level='#{(depth-1).to_s}'>#{article.xpath('breadcrumbs/crumb[4]/caption')[0].content.strip}</unit>\n")
							o.write("</structure>\n")
							o.write("<section_number>#{section_name}</section_number>\n")
							o.write("<catch_line>#{section.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
							o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
							o.write("<text>")
							o.write("<section>#{section.xpath('title[1]')[0].content.strip+' '+section.xpath('subtitle[1]')[0].content.strip}")
							section_parser.call(section,o)
							o.write("</section>")
							o.write("</text>")
							if(!section.xpath("comment[@note='historynote']").empty?)
								o.write("<history>#{section.xpath("comment[@note='historynote']")[0].content.strip}</history>")
							end							
							o.write("</law>")
							o.close
							global_section_count+=1
							section_count+=1
						end
						article_count+=1
					end
				else
					if(!chapter.xpath("section").empty?)
						section_count=1
						chapter.xpath("section").each do |section|
								depth=3
								section_name=section.xpath('title[1]')[0].content.strip.split(" ")[-1].gsub(/\.$/,"").gsub(/ /,'_');

								o=File.open("import-data/#{section_name}.xml","w+")
								o.write("<?xml version='1.0' encoding='utf-8'?>\n")
								o.write("<law>\n<structure>\n")
								o.write("<unit label='part' identifier='#{structure_name(1,part_count)} #{(part_count-1).to_s}' order_by='#{order_structure(part_count)}' level='#{(depth-2).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
								o.write("<unit label='chapter' identifier='#{order_structure(chapter_count)}' order_by='#{order_structure(chapter_count)}' level='#{(depth-1).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip}</unit>\n")
								o.write("</structure>\n")
								o.write("<section_number>#{section_name}</section_number>\n")
								o.write("<catch_line>#{section.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
								o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
								o.write("<text>")
								o.write("<section>#{section.xpath('title[1]')[0].content.strip+' '+section.xpath('subtitle[1]')[0].content.strip}")
								section_parser.call(section,o)
								o.write("</section>")
								o.write("</text>")
								if(!section.xpath("comment[@note='historynote']").empty?)
									o.write("<history>#{section.xpath("comment[@note='historynote']")[0].content.strip}</history>")
								end
								o.write("</law>")
								o.close
								section_count+=1
								global_section_count+=1
						end
					else
								depth=2
								if chapter.xpath("title[1]").empty?
									chapter_name=chapter.xpath('subtitle[1]')[0].content.strip.gsub(/ /,'_')

								else 
									chapter_name=chapter.xpath('title[1]')[0].content.strip+" "+chapter.xpath('subtitle[1]')[0].content.gsub(/ /,'_').strip

								end
								puts chapter_name
								o=File.open("import-data/#{chapter_name}.xml","w+")
								o.write("<?xml version='1.0' encoding='utf-8'?>\n")
								o.write("<law>\n<structure>\n")
								o.write("<unit label='part' identifier='#{structure_name(1,part_count)} #{(part_count-1).to_s}' order_by='#{order_structure(part_count)}' level='#{(depth-1).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
								o.write("<unit label='chapter' identifier='#{order_structure(chapter_count)}' order_by='#{order_structure(chapter_count)}' level='#{(depth).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip.squeeze(" ")}</unit>\n")
								o.write("</structure>\n")
								o.write("<section_number>abc</section_number>\n")
								o.write("<catch_line>#{chapter_name}</catch_line>\n")
								o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
								o.write("<text>")
								o.write("<section>#{chapter_name}")
								section_parser.call(chapter,o)
								o.write("</section>")
								o.write("</text>")
								if(!chapter.xpath("comment[@note='historynote']").empty?)
									o.write("<history>#{chapter.xpath("comment[@note='historynote']")[0].content.strip}</history>")
								end

								o.write("</law>")
								o.close
								global_section_count+=1
					end
				end
				chapter_count+=1
			end
		end
	part_count+=1
end




