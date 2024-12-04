import argparse
import json
import pdb
import sys

import json_repair #will have to pip install

def parse_json_file(json_filename):
    """reads through json file produced by a11ywatch API and displays the results.

    Parameters
    ----------
    json_filename : str
        name of the json file to process

    Returns
    -------
    rv : int
        if a11ywatch didn't find any issues, rv will be integer value '0'. However, if a11ywatch did find
        issues, rv will be integer value '99'.
    """
    # Fix any json formatting errors
    json_object = json_repair.from_file(json_filename)

    # pretty print json file contents
    json_formatted_str = json.dumps(json_object, indent=2)
    print(json_formatted_str)
    rv = 0
    return rv


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument( 'json_filename', type=str, help='Name of the json file to be processed')
    args = parser.parse_args()

    rv = parse_json_file(args.json_filename)
    sys.exit(rv)