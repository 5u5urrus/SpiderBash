#!/bin/bash

echo -e "Welcome to the smart & fun bash spidering tool."
echo -e "\033[92m Author: Vahe Demirkhanyan\n\r \033[0m"

echo "⣿⣿⣿⣿⣿⣿⣿⣉⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣿⣿⣷⡈⢿⣿⣿⣿⣿⣿⣿⡏⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣍⡙⢿⣿⣦⡙⠻⣿⣿⣿⡿⠁⣾⣿⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣿⣿⣦⡉⠛⠓⠢⡈⢿⡿⠁⣸⣿⡿⠿⢋⣴⣿⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣯⣍⣙⡋⠠⠄⠄⠄⠄⠁⠘⠁⠄⠴⠚⠻⢿⣿⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣿⡿⠿⢏⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠹⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣧⡴⠖⠒⠄⠁⠄⢀⠄⠄⠄⡀⠄⠄⠄⠄⠄⠄⣠⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣿⠿⠟⣩⣴⣶⣿⣿⣶⡞⠉⣠⣇⠄⣿⣶⣦⣄⡀⠲⢿⣿⣿⣿⣿⣿⣿⣿"
echo "⣿⣿⣷⣶⣾⣿⣿⣿⣿⣿⡿⢠⣿⣿⣿⢀⣿⣿⣿⣿⣿⣿⣶⣌⠻⠿⣿⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢡⣿⣿⣿⡏⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣾⣿⣿⣿"
echo "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣸⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"

echo -e "\n\r"

domain=$(echo $1|cut -d"/" -f3)
protocol=$(echo $1|cut -d":" -f1)

echo domain:$domain
echo protocol:$protocol

n=1
g=1
links3[1]=""

lev=$(($2+3))

user_agent="Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101 Firefox/91.0"
pattern="((http|https)://[a-zA-Z0-9./\+?=_-]+)|src=(\"|\'){1}\K.*?(?=(\"|\'){1})|href=(\"|\'){1}\K.*?(?=(\"|\'){1})"
extensions=".jpg|.gif|.jpeg|.png|mailto|javascript:|tel:|data:"
filters="31290842109124398421"

#[a-zA-Z0-9./?\+=_-]*\.js(?=(?|\'|\"|\s))

links=$(curl -L -A "$user_agent" -s $1 | grep -Poi "$pattern" | grep -vE "$extensions" | sort | uniq );

urls=$1

construct() {

u=$1
parent=$2

p=$(echo "$2"|cut -d"?" -f1)
u=$(echo "$u"|cut -d"#" -f1)

cu=$(echo "$u"|tr -cd '/' | wc -c)
cr=$(echo "$p"|tr -cd '/' | wc -c)


root=$(echo "$p"|cut -d"/" -f1-3)
rpath=""

if [[ $cr -ge 3 ]]
then
        rpath=$(echo "$p"|rev|cut -d"/" -f2-|rev)
else
        rpath="$p"
fi

#=============================first stage done

#echo "parent is $p"
#echo "root is $root"
#echo "rpath is $rpath"
#echo "cr is $cr"

#is there http?
if [[ "$u" == "http"* ]]
then
         echo "$u"
elif [[ "${u:0:2}" == "//" ]]
then
        echo "$protocol$u"
elif [[ "${u:0:1}" == "/" ]]
then
        echo "$root$u"
else
        echo "$rpath/$u"
fi

}


find_links() {
for i in $(echo $1)
do

     i=$(construct "$i" "$2")
     for f in $(echo $filters)
     do
	if [[ "$i" == *"$f"* ]]
	then
		continue 2
	fi
     done
     i2=$(echo "$i"|cut -f1 -d"?")
     t=$(echo "$i"| tr -cd '/' | wc -c)
     i3=""
     i4=""
     i5=""
     if [[ "$i" == *"?"* ]]
     then
        i3=$(echo "$i"|cut -d"/" -f4-|sed -e 's/[^?]*[?]//' -e 's/=[^&]*//g')
        i4="$i2?$i3"
     else
        i4="$i2"
     fi
     if [[ "${urls,,}" != *"${i4,,}"* ]] && [[ $t -lt $lev ]]
     then
	urls+=" $i"
	#echo "doing this $i"
	if [[ "$i" == *"http"* ]] && [[ "$i" == *"$domain"* ]] && [[ $t -lt $lev ]]
	then
		links3[$g]="$i"
		i5="$i"
		echo "Link $g: ${links3[$g]}"
	elif [[ "$i" == *"$domain"* ]] && [[ $((t+2)) -lt $lev ]]
	then
                links3[$g]="$protocol:$i"
		i5="$protocol:$i"
                echo "Link $g: ${links3[$g]}"
	elif [[ "$i" == *"http"* ]] && [[ "$i" != *"$domain"* ]] && [[ $t -lt $lev ]]
	then
		#links3[$g]="$i"
		#i5="$i"
 		#echo "Link $g: ${links3[$g]}"
		#g=$((g+1))
		continue
	elif [[ "$i" != *"$domain"* ]] && [[ "$i" == *"//"* ]] && [[ $((t+2)) -lt $lev ]]
	then
		#links3[$g]="$protocol:$i"
		#i5="$protocol:$i"
		#echo "Link $g: ${links3[$g]}"
		#g=$((g+1))
		continue
	elif [[ $((t+2)) -lt $lev ]]
	then
		links3[$g]="$protocol://$domain/$i"
		i5="$protocol://$domain/$i"
		echo "Link $g: ${links3[$g]}"
	fi
	g=$((g+1))
        l=$(curl -A "$user_agent" -s $i5 | grep -Poi "$pattern" |  grep -vE "$extensions" | sort | uniq );
        find_links "$l" "$i5"
     fi
done

}

r=""

#trapping ctrl+c
trap turnhere SIGINT

turnhere()
{
echo "you added a turn?"

read -p "Do you want to add any filters: " f
if [[ "$f" == "" ]]
	then
		exit
else
		filters="$filters $f"
		return
fi
}

find_links "$links" "" 
