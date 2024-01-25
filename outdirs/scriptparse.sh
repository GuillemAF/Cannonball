result=$(sqlite3 amass.sqlite -json "SELECT table1.content,assets.content FROM (SELECT assets.id AS id, assets.content AS content FROM assets WHERE assets.content LIKE '%name%hueverasdecarton%') AS table1 INNER JOIN relations,assets WHERE relations.from_asset_id=table1.id AND relations.to_asset_id=assets.id;" | jq -c '.[]' | jq -c '(.content | fromjson) + (.content | fromjson)' | jq -r '"\(.name?) \(.address?)"' | tr ' ' '\n')

filtered_result=""

for i in $result
do 
    if [ "$i" != "null" ]; then
        filtered_result="$filtered_result $i"
    fi
done

echo "$filtered_result" | tr ' ' '\n'


