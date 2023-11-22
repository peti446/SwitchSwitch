#!/bin/bash

if [ -f ".env" ]; then
	. ".env"
fi

declare -A translationStrings
translationTempFile=$(mktemp)
regex='L\[\"([^]]+)\"\]'
projectID=299998

process_addon_translations(){
while read -r line || [ -n "$line" ] ; do
	if [[ $line =~ $regex ]] ; then
		translationStrings["${BASH_REMATCH[1]}"]=true
	fi
done < <(cat "$1" | grep -oP $regex);
}

while IFS= read -r -d '' line; do
	process_addon_translations "$line"
done < <(find . -type f -name "*.lua" -not -path "*/Locales/*" -not -path "*/Libs/*" -not -path "*/.release/*" -print0)

for x in "${!translationStrings[@]}"; do
	printf "L[\"%s\"] = %s\n" "$x" "${translationStrings[$x]}" >> "$translationTempFile"
done

#language: "enUS", //[enUS, deDE, esES, ect], Required, No Default
#       namespace: "toc", //Any namespace name, comma delimited. Default: Base Namespace
#       formatType: TableAdditions, //['GlobalStrings','TableAdditions','SimpleTable']. Default: TableAdditions
#       missing-phrase-handling: DoNothing //['DoNothing', 'DeleteIfNoTranslations', 'DeleteIfTranslationsOnlyExistForSelectedLanguage', 'DeletePhrase']. Default: DoNothing
#   localizations: "Localizations To Import"

result=$( curl -sS -0 -o /dev/null -X POST -w "%{http_code}" \
-H "X-Api-Token: $CF_API_KEY" \
-F "metadata={ language: \"enUS\", formatType: \"TableAdditions\", \"missing-phrase-handling\": \"DeletePhrase\" }" \
-F "localizations=<$translationTempFile" \
"https://legacy.curseforge.com/api/projects/$projectID/localization/import"
) || exit 1

case $result in
200)
  echo "Exported localisation string to curse forge."
  exit 0
  ;;
*)
  echo -e "Error exporting localisation to curse forge. Response:\n $result \n"
  exit 1
  ;;
esac

