#! /bin/bash

sites_file='/Users/lakesh/Desktop/sites_final.txt'
sites=`cat $sites_file`
aot_path='/Users/lakesh/Downloads/AOT/LEV20/ALL_POINTS/AERONET_data'


for site in $sites
do
   available=`ls $aot_path | grep ^$site\.mat$`
   #echo $available
   if [ $available ]
   then
      echo $site
      echo $site >> selected_sites.txt
   fi

done 

