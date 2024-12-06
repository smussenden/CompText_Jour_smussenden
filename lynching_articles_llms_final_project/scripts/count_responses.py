import os
import sys

def count_rds_files(directory):
    top_level = os.path.basename(directory)
    for root, dirs, files in os.walk(directory):
        rds_count = sum(1 for file in files if file.endswith('.rds'))
        relative_path = os.path.relpath(root, directory)
        if relative_path == '.':
            relative_path = ''
        else:
            relative_path = os.path.relpath(root, os.path.join(directory, '..'))
        print(f"{relative_path}: {rds_count} .rds files")

if __name__ == "__main__":
    directory = os.path.join(os.path.dirname(__file__), '../llm_responses')
    count_rds_files(directory)