echo "T=Tom J=Jerry B=Bird D=Dog"
echo "<password> <level>"
./bruteforcer | awk '{if (substr($1,1,1)=="J") print $1 " " "2";if (substr($1,1,1)=="T") print $1 " " "3";if (substr($1,1,1)=="B") print $1 " " "4";if (substr($1,1,1)=="D") print $1 " " "5"}' | sort -k 2 | awk '{print $2 " " $1}' | uniq -w 2
