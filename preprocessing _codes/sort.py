#! /usr/bin/python

import sys

sites_file = open('selected_sites.txt');
sites = sites_file.read().split("\n");
sites.sort();

for site in sites:
    print site


