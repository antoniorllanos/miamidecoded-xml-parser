
require 'nokogiri'
f=File.open("test_short.xml","r+")
doc=Nokogiri::XML(f)
part_count=1
doc.xpath("book/level1").each do |tag|
	tag.xpath("breadcrumbs/crumb[2]/caption").each do |part|
		if part_count==3
		else
			depth=1
			chapter_count=1
			tag.xpath("level2").each do |chapter|
				depth=2						
				
				if(!chapter.xpath("level3").empty?)
					article_count=1
					chapter.xpath("level3").each do |article|
						depth=3
						section_count=1
						article.xpath("section").each do |section|
							depth=4
							section_name=section.xpath('title[1]')[0].content.strip.split(" ")[1][0..-2]
							o=File.open("parsed/#{section_name}.xml","w+")
							o.write("<?xml version='1.0' encoding='utf-8'?>\n")
							o.write("<law>\n<structure>\n")
							o.write("<unit label='part' identifier='#{part_count.to_s}' order_by='#{part_count.to_s}' level='#{(depth-3).to_s}'>#{part.content.strip}</unit>\n")
							o.write("<unit label='chapter' identifier='#{part_count.to_s+'.'+chapter_count.to_s}' order_by='#{part_count.to_s+'.'+chapter_count.to_s}' level='#{(depth-2).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip}</unit>\n")
							o.write("<unit label='article' identifier='#{part_count.to_s+'.'+chapter_count.to_s+'.'+article_count.to_s}' order_by='#{part_count.to_s+'.'+chapter_count.to_s+'.'+article_count.to_s}' level='#{(depth-1).to_s}'>#{article.xpath('breadcrumbs/crumb[4]/caption')[0].content.strip}</unit>\n")
							o.write("</structure>\n")
							o.write("<section_number>#{section_name}</section_number>\n")
							o.write("<catch_line>#{section.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
							o.write("<order_by>#{part_count.to_s+'.'+chapter_count.to_s+'.'+article_count.to_s+'.'+section_count.to_s}</order_by>\n")
							o.write("<text>\n<section>#{section.xpath('title[1]')[0].content.strip+' '+section.xpath('subtitle[1]')[0].content.strip}</section>\n</text>\n")
							#section.xpath("para").each do |para|
								#o.write(para.content)
							#end
							o.write("</law>\n")
							o.close
							section_count+=1
						end
						article_count+=1
					end
				else
					if(!chapter.xpath("section").empty?)
						section_count=1
						chapter.xpath("section").each do |section|
								depth=3
								section_name=section.xpath('title[1]')[0].content.strip.split(" ")[1][0..-2]
								o=File.open("parsed/#{section_name}.xml","w+")
								o.write("<?xml version='1.0' encoding='utf-8'?>\n")
								o.write("<law>\n<structure>\n")
								o.write("<unit label='part' identifier='#{part_count.to_s}' order_by='#{part_count.to_s}' level='#{(depth-2).to_s}'>#{part.content.strip}</unit>\n")
								o.write("<unit label='chapter' identifier='#{part_count.to_s+'.'+chapter_count.to_s}' order_by='#{part_count.to_s+'.'+chapter_count.to_s}' level='#{(depth-1).to_s}'>#{chapter.xpath('breadcrumbs/crumb[3]/caption')[0].content.strip}</unit>\n")
								o.write("</structure>\n")
								o.write("<section_number>#{section_name}</section_number>\n")
								o.write("<catch_line>#{section.xpath('subtitle[1]')[0].content.strip}</catch_line>\n")
								o.write("<order_by>#{part_count.to_s+'.'+chapter_count.to_s+'.'+article_count.to_s+'.'+section_count.to_s}</order_by>\n")
								o.write("<text>\n<section>#{section.xpath('title[1]')[0].content.strip+' '+section.xpath('subtitle[1]')[0].content.strip}</section>\n</text>\n")
								#section.xpath("para").each do |para|
									#o.write(para.content)
								#end
								o.write("</law>\n")
								o.close
								section_count+=1
						end
					else
					end
				end
				chapter_count+=1
			end
		end
	end
	part_count+=1
end



