import xml.etree.ElementTree as ET
import requests

url = "https://storage.googleapis.com/torrent-stuff/"

def convert_size(size_in_bytes):
  suffixes = ['B', 'KB', 'MB', 'GB', 'TB']
  index = 0
  while size_in_bytes >= 1024 and index < len(suffixes) - 1:
    size_in_bytes /= 1024.0
    index += 1

  size_formatted = "{:.2f}".format(size_in_bytes)

  return f"{size_formatted} {suffixes[index]}"

try:
  response = requests.get(url)
  if response.status_code == 200:
    xml_content = response.content
    #print(xml_content)
    root = ET.fromstring(xml_content)

    result_dict = {}

    for content in root.findall(".//{http://doc.s3.amazonaws.com/2006-03-01}Contents"):
      key = content.findtext("{http://doc.s3.amazonaws.com/2006-03-01}Key")
      generation = content.findtext("{http://doc.s3.amazonaws.com/2006-03-01}Generation")
      meta_generation = content.findtext("{http://doc.s3.amazonaws.com/2006-03-01}MetaGeneration")
      last_modified = content.findtext("{http://doc.s3.amazonaws.com/2006-03-01}LastModified")
      etag = content.findtext("{http://doc.s3.amazonaws.com/2006-03-01}ETag")
      size = content.findtext("{http://doc.s3.amazonaws.com/2006-03-01}Size")

      content_data = {
        "Key": key,
        #"Generation": generation,
        #"MetaGeneration": meta_generation,
        "LastModified": last_modified,
        #"ETag": etag,
        "Size": convert_size(int(size))
      }

      result_dict[key] = content_data
    print(result_dict)
  else:
    print(f"Failed to retrieve XML. Status code: {response.status_code}")

except Exception as e:
  print(f"An error occurred: {str(e)}")
