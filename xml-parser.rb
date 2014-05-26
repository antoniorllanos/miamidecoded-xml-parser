def order_by(integer)
	return "0"*(10-integer.to_s.length)+integer.to_s
end

require 'nokogiri'

section_parser=Proc.new do |section,o|
	section.xpath('para|listitem').each do |item|
		if item.name=="listitem"
			prefix=item.xpath('incr')[0].content
			content=item.xpath('content')[0].content
			o.write("\n<section prefix='#{prefix}'>#{content}")
			section_parser.call(item,o)
			o.write("</section>\n")
		else
			content=item.xpath("text()").to_s.gsub(/[\n\r]/,"").gsub(/\s+/," ").strip
			o.write("\n<section>#{content}")
			section_parser.call(item,o)
			o.write("</section>\n")
		end
	end
end


f=File.open("raw_dump.xml","r+")
doc=Nokogiri::XML(f)
global_section_count=1
part_count=1
doc.xpath("book/level1").each do |part|
		if part_count==3
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
							section_name=section.xpath('title[1]')[0].content.strip.split(" ")[-1][0..-2]
							o=File.open("import-data/#{section_name}.xml","w+")
							o.write("<?xml version='1.0' encoding='utf-8'?>\n")
							o.write("<law>\n<structure>\n")
							o.write("<unit label='part' identifier='#{part_count.to_s}' order_by='#{part_count.to_s}' level='#{(depth-3).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
							o.write("<unit label='chapter' identifier='#{part_count.to_s+'.'+chapter_count.to_s}' order_by='#{part_count.to_s+'.'+chapter_count.to_s}' level='#{(depth-2).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip}</unit>\n")
							o.write("<unit label='article' identifier='#{part_count.to_s+'.'+chapter_count.to_s+'.'+article_count.to_s}' order_by='#{part_count.to_s+'.'+chapter_count.to_s+'.'+article_count.to_s}' level='#{(depth-1).to_s}'>#{article.xpath('breadcrumbs/crumb[4]/caption')[0].content.strip}</unit>\n")
							o.write("</structure>\n")
							o.write("<section_number>#{section_name}</section_number>\n")
							o.write("<catch_line>#{section.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
							o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
							o.write("<text>\n<section>#{section.xpath('title[1]')[0].content.strip+' '+section.xpath('subtitle[1]')[0].content.strip}</section>\n</text>\n")
							#section.xpath("para").each do |para|
								#o.write(para.content)
							#end
							
							o.write("</law>\n")
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
								section_name=section.xpath('title[1]')[0].content.strip.split(" ")[-1][0..-2]
								o=File.open("import-data/#{section_name}.xml","w+")
								o.write("<?xml version='1.0' encoding='utf-8'?>\n")
								o.write("<law>\n<structure>\n")
								o.write("<unit label='part' identifier='#{part_count.to_s}' order_by='#{part_count.to_s}' level='#{(depth-2).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
								o.write("<unit label='chapter' identifier='#{part_count.to_s+'.'+chapter_count.to_s}' order_by='#{part_count.to_s+'.'+chapter_count.to_s}' level='#{(depth-1).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip}</unit>\n")
								o.write("</structure>\n")
								o.write("<section_number>#{section_name}</section_number>\n")
								o.write("<catch_line>#{section.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
								o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
								o.write("<text>\n")
								o.write("<section>#{section.xpath('title[1]')[0].content.strip+' '+section.xpath('subtitle[1]')[0].content.strip}")
								section_parser.call(section,o)
								o.write("</section>\n")
								o.write("</text>")
								if(!section.xpath("comment[@note='historynote']").empty?)
									o.write("<history>#{section.xpath("comment[@note='historynote']")[0].content.strip}</history>")
								end
								#section.xpath("para").each do |para|
									#o.write(para.content)
								#end
								o.write("</law>\n")
								o.close
								section_count+=1
								global_section_count+=1
						end
					else
								depth=2
								if chapter.xpath("title[1]").empty?
									chapter_name=chapter.xpath('subtitle[1]')[0].content.strip
								else 
									chapter_name=chapter.xpath('title[1]')[0].content.strip+" "+chapter.xpath('subtitle[1]')[0].content.strip
								end
								o=File.open("import-data/#{chapter_name}.xml","w+")
								o.write("<?xml version='1.0' encoding='utf-8'?>\n")
								o.write("<law>\n<structure>\n")
								o.write("<unit label='part' identifier='#{part_count.to_s}' order_by='#{part_count.to_s}' level='#{(depth-1).to_s}'>#{part.xpath('breadcrumbs/crumb[2]/caption')[0].content.strip}</unit>\n")
								o.write("</structure>\n")
								o.write("<section_number>#{chapter_name}</section_number>\n")
								o.write("<order_by>#{order_by(global_section_count)}</order_by>\n")
								o.write("<text>\n")
								o.write("<section>#{chapter_name}")
								section_parser.call(chapter,o)
								o.write("</section>\n")
								o.write("</text>")
								if(!chapter.xpath("comment[@note='historynote']").empty?)
									o.write("<history>#{chapter.xpath("comment[@note='historynote']")[0].content.strip}</history>")
								end
								#section.xpath("para").each do |para|
									#o.write(para.content)
								#end
								o.write("</law>\n")
								o.close
								global_section_count+=1
					end
				end
				chapter_count+=1
			end
		end
	part_count+=1
end




