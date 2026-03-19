#!/usr/bin/env python3

import importlib
import importlib.util
import subprocess
import sys
import time
import argparse
import pathlib
import datetime
import re

# Dependency check 

def ensure_dependencies():
	required = {
		"requests": "requests",
		"bs4": "beautifulsoup4"
	}

	for import_name, package_name in required.items():
		if importlib.util.find_spec(import_name) is None:
			print(f"{package_name} not found - installing...")
			subprocess.run(
				[sys.executable, "-m", "pip", "install",
				package_name, "--break-system-packages"],
				check=True
			)
			print(f"{package_name} installed successfully.")

# ensure_dependencies() # commented out for repo version

# Third party imports - required, and also checked for by: ensure_dependencies()
import requests
from bs4 import BeautifulSoup

def get_year_urls(base_url):
	response = requests.get(base_url + "/hugo-history/")
	soup = BeautifulSoup(response.text, "html.parser")
	content_div = soup.find("div", class_="entry-content")
	year_links = content_div.find_all("a")
	urls = []
	for link in year_links:
		href = link.get("href")
		if href and re.search(r'/\d{4}-hugo-awards/', href):
			if href.startswith("http"):
				urls.append(href)
			else:
				urls.append(base_url + href)
	return urls

def parse_year_page(url, author_name):
	response = requests.get(url)
	soup = BeautifulSoup(response.text, "html.parser")
	content_div = soup.find("div", class_="entry-content")

	results = []
	current_category = "Unknown Category"

	for element in content_div.children:
		# Category heading check
		if element.name == "p":
			current_category = element.get_text(strip=True)
		# Check for nomination list
		elif element.name == "ul":
			for li in element.find_all("li"):
				nomination_text = li.get_text(strip=True, separator=" ")
		
				if author_name.lower() in nomination_text.lower():
					is_winner = "winner" in li.get("class", [])
					results.append({
						"category": current_category,
						"nomination": nomination_text,
						"winner": is_winner
					})
	return results

def write_results(author_name, all_results, output_file):
	with open(output_file, "w") as f:
		f.write(f"Hugo Awards results for: {author_name}\n")
		f.write(f"Generated: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
		f.write("=" * 50 + "\n\n")

		if not all_results:
			f.write("No nominations or wins found for this author.\n")
			return
	
		for year, results in sorted(all_results.items()):
			f.write(f"{year}\n")
			f.write("-" * 30 + "\n")
			for result in results:
				status = "WINNER" if result["winner"] else "Nominated"
				f.write(f"[{status}] {result['category']}\n")
				f.write(f"{result['nomination']}\n\n")

def parse_arguments():
	parser = argparse.ArgumentParser(description="Hugo Awards author lookup")
	parser.add_argument("author", help="Author name to search for")
	parser.add_argument(
		"--output",
		type=str,
		default=None,
		help="Output file path (default: author_name_hugo_awards.txt)"
	)
	return parser.parse_args()

def main():
	args = parse_arguments()
	author_name = args.author

	base_url = "https://www.thehugoawards.org"

	# Generate default output filename if not specified
	if args.output is None:
		safe_name = author_name.lower().replace(" ", "_")
		output_file = pathlib.Path(f"{safe_name}_hugo_awards.txt")
	else:
		output_file = pathlib.Path(args.output)

	print(f"Searching Hugo Awards history for: {author_name}")
	print("This may take some time - indexing each year page...")

	year_urls = get_year_urls(base_url)
	all_results = {}

	for url in year_urls:
		# Extract year from URL labeling
		year = url.rstrip("/").split("/")[-1]

		print(f"Checking {year}...")

		results = parse_year_page(url, author_name)
		if results:
			all_results[year] = results
	
		# Rate limiting 
		time.sleep(1)
	
	write_results(author_name, all_results, output_file)
	print(f"\nComplete. Results written to {output_file}")

if __name__ == "__main__":
	main()
