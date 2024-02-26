import json
import argparse
import sys

def parse_list(arg_val):
    """Converts a comma-separated string to a list."""
    return arg_val.split(',') if arg_val else []

def update_json(file_path, name=None, fullname=None, parents=None, propositus=None, siblings=None):
    """Loads JSON data, shows planned changes, and prompts for confirmation before saving."""
    with open(file_path, 'r') as file:
        data = json.load(file)

    changes = {}
    if name:
        changes['Run_Name'] = name
    if fullname:
        changes['Run_Full_Name'] = fullname
    if parents:
        changes['Exome']['Parents'] = parse_list(parents)
    if propositus:
        changes['Exome']['Propositus'] = [parse_list(propositus)]
    if siblings:
        changes['Exome']['Siblings'] = parse_list(siblings)

    # Display planned changes for review
    print("Planned changes:")
    for key, value in changes.items():
        print(f"{key}: {value}")

    # Prompt for confirmation to apply changes
    confirm = input("Apply these changes? (y/n): ")
    if confirm.lower() != 'y':
        print("Changes aborted.")
        return

    # Merge the changes into the original data
    for key, path in changes.items():
        nested_keys = key.split('.')
        current_level = data
        for part in nested_keys[:-1]:
            current_level = current_level.setdefault(part, {})
        current_level[nested_keys[-1]] = path

    # Save the updated data back to the file
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)
    print("JSON file updated successfully.")

def main():
    """Parses command-line arguments to update specific JSON file fields."""
    parser = argparse.ArgumentParser(description='Update values in a JSON file with a preview of changes.')

    parser.add_argument('--file', required=True, help='Path to the JSON file')
    parser.add_argument('--name', required=True, help='Value to replace Run_Name')
    parser.add_argument('--fullname', required=True, help='Value to replace Run_Full_Name')
    parser.add_argument('--parents', required=True, help='Comma-separated values to replace Exome.Parents')
    parser.add_argument('--propositus', required=True, help='Comma-separated values to replace Exome.Propositus')
    parser.add_argument('--siblings', help='Comma-separated values to replace Exome.Siblings')

    if len(sys.argv) == 1 or any(arg not in sys.argv for arg in ['--file', '--name', '--fullname', '--parents', '--propositus']):
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()
    update_json(args.file, args.name, args.fullname, args.parents, args.propositus, args.siblings)

if __name__ == "__main__":
    main()
