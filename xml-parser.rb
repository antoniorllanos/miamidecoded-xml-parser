
require 'nokogiri'
f=File.open("raw_dump.xml","r+")
o=File.open("output_file.xml","w+")
o.write("<?xml version='1.0' encoding='utf-8'?>\n<law>\n<structure>")
doc=Nokogiri::XML(f)
part_count=1
doc.xpath("book/level1").each do |tag|
	tag.xpath("breadcrumbs/crumb[2]/caption").each do |part|
		depth=1
		o.write("<unit label='part' identifier=#{part_count.to_s} order_by=#{part_count.to_s} level=#{depth.to_s}>#{part.content}</unit>\n")
		article_count=1
		tag.xpath("level2").each do |article|
			depth=2
			o.write("<unit label='article' identifier=#{part_count.to_s+'.'+article_count.to_s} order_by=#{part_count.to_s+'.'+article_count.to_s} level=#{depth.to_s}>#{article.xpath('breadcrumbs/crumb[3]/caption')[0].content}</unit>\n")
			article_count+=1
			chapter_count=1
			article.xpath("level3").each do |chapter|
				depth=3
				o.write("<unit label='chapter' identifier=#{part_count.to_s+'.'+article_count.to_s+'.'+chapter_count.to_s} order_by=#{part_count.to_s+'.'+article_count.to_s+'.'+chapter_count.to_s} level=#{depth.to_s}>#{chapter.xpath('breadcrumbs/crumb[4]/caption')[0].content}</unit>\n</")
				chapter_count+=1
				section_count=1
				chapter.xpath("section").each do |section|
					depth=4
					o.write("<unit label='section' identifier=#{part_count.to_s+'.'+article_count.to_s+'.'+chapter_count.to_s+'.'+section_count.to_s} order_by=#{part_count.to_s+'.'+article_count.to_s+'.'+chapter_count.to_s+'.'+section_count.to_s} level=#{depth.to_s}>#{section.xpath('title[1]')[0].content+' '+section.xpath('subtitle[1]')[0].content}</unit>\n</")
					section_count+=1
				end
			end
		end
	end
	part_count+=1
end



