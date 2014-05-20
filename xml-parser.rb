class LegalCode
	def initialize(xml_file)
		f=File.open(xml_file,"r+")
		doc=Nokogiri::XML(f)
		info_tag=doc.xpath("book/bookinfo")
		puts info_tag.xpath("title")
	end
end

require 'nokogiri'
f=File.open("raw_dump.xml","r+")
doc=Nokogiri::XML(f)
content={"section"=>{}}
doc.xpath("book/level1").each do |tag|
	tag.xpath("breadcrumbs/crumb[2]/caption").each do |section|
		content["section"][section.content.strip]={}
		tag.xpath("level2/breadcrumbs/crumb[3]/caption").each do |article|
			content["section"][section.content.strip][article.content.strip]={}
		end
	end
end

LegalCode.new("raw_dump.xml")

