import json
import json_repair #will have to pip install
import pdb

json_filename = 'barf1.json'

# Fix any json formatting errors
json_object = json_repair.from_file(json_filename)

# pretty print json filecld
json_formatted_str = json.dumps(json_object, indent=2)
print(json_formatted_str)
pdb.set_trace()