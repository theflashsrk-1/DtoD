#!/bin/bash

# Check if the required number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <symbol>"
    exit 1
fi

symbol="$1"
#symbol="ABFRL"
expiry="2024-05-30"
filterdate1="2024-05-23"
filtertime="09:24"
filterdate="${filterdate1// /}T09:25"
cookie="_ga=GA1.1.1702999957.1698264249;PHPSESSID=up0qpu3iem2pc10prl1hooub0s;usertype=User;__cflb=02DiuGUtYpCvq4WPmeg4tCsHMhsiGNWBQeXg5p4SLpQsE;_fbp=fb.1.1708888315316.1951407820;_ga_RRP4199HWQ=GS1.1.1705291197.34.0.1705291197.60.0.0;amp_6e403e=LNdolaKxmJkN_om7B0iLYM...1hf4gaqlf.1hf4gb4qd.0.0.0;ltp_login_token=aKQcf5S2pU6yiF2CyhxgYKRMdYv9jBo3eGDatx85;username=Shaan%20Kalani"

# Define the variables

host="ltp.investingdaddy.com"
user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0"

# Get the curl output
curl_output=$(curl -i -s -k -X GET \
    -H "Host: $host" \
    -H "User-Agent: $user_agent" \
    -b "$cookie" \
    "https://ltp.investingdaddy.com/historical-option-chain.php?symbol=$symbol&expiry=$expiry&filterdate1=$filterdate1&filtertime=$filtertime&filterdate=$filterdate")

# Define the keyword
keyword="border-bottom:1px solid red;"
Current_market_price_kw="font-size: 14px;font-weight: 200;margin-bottom:0;color : white"

# Extract the line number of the keyword from curl output
line_number=$(echo "$curl_output" | grep -n "$keyword" | cut -d: -f1)

# Get the line 24 lines below the keyword line number from curl output
value_from_curl=$(echo "$curl_output" | sed -n "$((line_number + 24))p" | sed -e 's/^[[:space:]]*//'| sed 's/<td style="cursor: pointer;" class="" //')

# Get the line 49 lines below the keyword line number from curl output
value2_from_curl=$(echo "$curl_output" | sed -n "$((line_number + 49))p" | sed -e 's/^[[:space:]]*//'| sed 's/<td style="cursor: pointer;" class=" "//')

# Get the line 13 lines below the keyword line number from curl output
value3_from_curl=$(echo "$curl_output" | sed -n "$((line_number + 13))p" | sed -e 's/^[[:space:]]*//'| sed 's/<td style="cursor: pointer;" class="itmhighlight " //')

# Get the line 58 lines below the keyword line number from curl outpu
value4_from_curl=$(echo "$curl_output" | sed -n "$((line_number + 60))p" | sed -e 's/^[[:space:]]*//'| sed 's/<td style="cursor: pointer;" class="itmhighlight" //')


# Extract the onclick attribute values from curl output
onclick_value=$(echo "$value_from_curl"  | sed -n '/onclick="getVolumeCalculate/s/.*(\([^)]*\)).*/\1/p')
onclick2_value=$(echo "$value2_from_curl"  | sed -n '/onclick="getVolumeCalculate/s/.*(\([^)]*\)).*/\1/p')
onclick3_value=$(echo "$value3_from_curl"  | sed -n '/onclick="getVolumeCalculate/s/.*(\([^)]*\)).*/\1/p')
onclick4_value=$(echo "$value4_from_curl"  | sed -n '/onclick="getVolumeCalculate/s/.*(\([^)]*\)).*/\1/p')

# Remove leading and trailing spaces and quotes
onclick_value=$(echo "$value_from_curl" | sed 's/onclick="getVolumeCalculate(\([^)]*\))"/\1/' | xargs)
onclick2_value=$(echo "$value2_from_curl" | sed 's/onclick="getVolumeCalculate(\([^)]*\))"/\1/' | xargs)
onclick3_value=$(echo "$value3_from_curl" | sed 's/onclick="getVolumeCalculate(\([^)]*\))"/\1/' | xargs)
onclick4_value=$(echo "$value4_from_curl" | sed 's/onclick="getVolumeCalculate(\([^)]*\))"/\1/' | xargs)

# Remove leading and trailing spaces and quotes for Current market price
current_value=$(echo "$curl_output"| grep -n "$Current_market_price_kw" | sed -n 's/.*white">\([0-9.]*\)<\/label>.*/\1/p' | xargs)

# Extract the parameters
IFS=, read -r param1 param2 param3 <<<"$onclick_value"
IFS=, read -r param4 param5 param6 <<<"$onclick2_value"
IFS=, read -r param7 param8 param9 <<<"$onclick3_value"
IFS=, read -r param10 param11 param12 <<<"$onclick4_value"

IFS=, read -r param13  <<<"$current_value"

# Assign to variables
Current_market_value=$param13

# c1,p1 api variables
put1=$param7
value_2=$param8

call1=$param10
value_3=$param11

# c2,p2 api variables
put2=$param4
value_1=$param5

call2=$param1
value=$param2

#STAGE_2 Getting reversal value of Call-1

sym="$symbol"
get="getBothReversal"
cp="$call1"
mp="$Current_market_value"
sp="$value_3"
time="$filterdate"

curl_api_output=$(curl -i -s -k -X POST \
    -H 'Host: ltp.investingdaddy.com' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0' \
    -b "$cookie" \
    --data-binary "action=$get&cepe=$cp&cmp=$mp&expiry=$expiry&symbol=$sym&strikeprice=$sp&label_text=Target+can+be&datetime=$time" \
    'https://ltp.investingdaddy.com/api.php')

#Extrating the reversal values and grepping all the junk out
Call1=$(echo $curl_api_output | grep -o 'blink;">[^<]*' | sed 's/blink;">//')

#STAGE_3 Getting reversal value of Put-1

get="getBothReversal"
cp="$put1"
mp="$Current_market_value"
sp="$value_2"
time="$filterdate"

curl_api_output=$(curl -i -s -k -X POST \
    -H 'Host: ltp.investingdaddy.com' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0' \
    -b "$cookie" \
    --data-binary "action=$get&cepe=$cp&cmp=$mp&expiry=$expiry&symbol=$sym&strikeprice=$sp&label_text=Target+can+be&datetime=$time" \
    'https://ltp.investingdaddy.com/api.php')

#Extrating the reversal values and grepping all the junk out
Put1=$(echo $curl_api_output | grep -o 'blink;">[^<]*' | sed 's/blink;">//')

#STAGE_4 Getting reversal value of Call-2

sym="$symbol"
get="getBothReversal"
cp="$call2"
mp="$Current_market_value"
sp="$value"
time="$filterdate"

curl_api_output=$(curl -i -s -k -X POST \
    -H 'Host: ltp.investingdaddy.com' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0' \
    -b "$cookie" \
    --data-binary "action=$get&cepe=$cp&cmp=$mp&expiry=$expiry&symbol=$sym&strikeprice=$sp&label_text=Target+can+be&datetime=$time" \
    'https://ltp.investingdaddy.com/api.php')

#Extrating the reversal values and grepping all the junk out
Call2=$(echo $curl_api_output | grep -o 'blink;">[^<]*' | sed 's/blink;">//')


#STAGE_5 Getting reversal value of Put-2

get="getBothReversal"
cp="$put2"
mp="$Current_market_value"
sp="$value_1"
time="$filterdate"

curl_api_output=$(curl -i -s -k -X POST \
    -H 'Host: ltp.investingdaddy.com' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:123.0) Gecko/20100101 Firefox/123.0' \
    -b "$cookie" \
    --data-binary "action=$get&cepe=$cp&cmp=$mp&expiry=$expiry&symbol=$sym&strikeprice=$sp&label_text=Target+can+be&datetime=$time" \
    'https://ltp.investingdaddy.com/api.php')

#Extrating the reversal values and grepping all the junk out
Put2=$(echo $curl_api_output | grep -o 'blink;">[^<]*' | sed 's/blink;">//')

# Define ANSI escape codes for colors and formatting

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'


# Print the variables

#echo $symbol
#echo "market price: $Current_market_value"
#echo "Call 1: $Call1"
#echo "Call 2: $Call2"
#echo "Put 1: $Put1"
#echo "Put 2: $Put2"


#print with zist!

echo -e "${YELLOW}$symbol"
echo -e "market price: $Current_market_value\n"
echo -e "${GREEN} Call 1: $Call1"
echo -e "${GREEN} Call 2: $Call2\n"
echo -e "${RED} Put 1: $Put1"
echo -e "${RED} Put 2: $Put2${NC}\n\n"





